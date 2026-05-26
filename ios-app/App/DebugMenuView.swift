#if DEBUG
import ComposableArchitecture
import SwiftUI
import Domain
import FirebaseAuth
import FirebaseMessaging
import TabbarFeature
import DesignSystem
import Logger

extension Bootstrap: @retroactive Identifiable {
    public var id: UUID {
        UUID()
    }
}

private struct _DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    init?(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
}

extension Bootstrap: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: _DynamicCodingKey.self)
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let label = child.label else { continue }
            // We don't know the concrete types here, so encode a readable string representation
            let valueDescription = String(describing: child.value)
            try container.encode(valueDescription, forKey: _DynamicCodingKey(stringValue: label)!)
        }
    }
}

private enum E2EAutoLoginConfig {
    static let enabledKey = "E2E_ENABLE_AUTO_LOGIN"
    static let tokenKey = "E2E_CUSTOM_TOKEN"

    static func tokenFromLaunchArguments() -> String? {
        let userDefaults = UserDefaults.standard
        let enabled = (userDefaults.string(forKey: enabledKey) ?? ProcessInfo.processInfo.environment[enabledKey]) == "1"
        guard enabled else { return nil }
        let token = userDefaults.string(forKey: tokenKey) ?? ProcessInfo.processInfo.environment[tokenKey]
        guard let token, !token.isEmpty else { return nil }
        return token
    }
}

struct DebugMenuView: View {
    @State var debugMenuExpanded: Bool = false
    @State var hideDebugMenu: Bool = false
    @State var alert: String?
    @State var sessionSheet: Bootstrap?
    @State private var localSession: Bootstrap?
    @State private var didAttemptE2EAutoLogin = false
    let apiClient: APIClient
    let notificationClient: NotificationClient

    private func prettyJSONString<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @MainActor
    private func handleSuccess(_ message: String) {
        alert = message
        hideDebugMenu = true
        Logger.debug(message)
    }

    @MainActor
    private func runAction(actionName: String, operation: @escaping () async throws -> Void) async {
        do {
            try await operation()
            handleSuccess("\(actionName) succeeded")
        } catch {
            alert = error.localizedDescription
            Logger.debug(error.localizedDescription)
        }
    }

    var body: some View {
        if !hideDebugMenu {
            HStack {
                Button {
                    withAnimation {
                        self.debugMenuExpanded.toggle()
                    }
                } label: {
                    Image.chevronCompactDown
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding()
                }
                if debugMenuExpanded {
                    VStack {
                        Button("Show session data") {
                            Task {
                                await runAction(actionName: "Show session data") {
                                    let session = try await apiClient.getBootstrap()
                                    self.sessionSheet = session
                                }
                            }
                        }
                        Button("Print id token") {
                            Task {
                                await runAction(actionName: "Print id token") {
                                    let token = try await Auth.auth().currentUser?.getIDToken()
                                    Logger.debug(token ?? "Not found")
                                }
                            }
                        }
                        Button("Print fcm token") {
                            Task { @MainActor in
                                Logger.debug(Messaging.messaging().fcmToken ?? "Not found")
                                handleSuccess("Print fcm token succeeded")
                            }
                        }
                        Button("Local mock notification") {
                            Task {
                                await runAction(actionName: "Local mock notification") {
                                    notificationClient.scheduleLocalNotification(
                                        title: "mock title",
                                        body: "mock body",
                                        userInfo: [:],
                                        presentAfterDelayInSeconds: 5,
                                        id: "mock_notification"
                                    )
                                }
                            }
                        }
                        Button("Crash") {
                            fatalError("Debug crash")
                        }
                        Button("Logout") {
                            Task {
                                await runAction(actionName: "Logout") {
                                    try Auth.auth().signOut()
                                }
                            }
                        }
                        Button("Hide") {
                            alert = "Hide succeeded"
                            hideDebugMenu = true
                        }
                        if let alert {
                            Text(alert)
                                .captionTextStyle()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 220)
                        }
                    }
                    .padding()
                }
            }
            .sheet(item: $sessionSheet, content: { session in
                NavigationStack {
                    List {
                        Section("Server session") {
                            if let jsonString = prettyJSONString(session) {
                                Text(jsonString)
                                    .supportingTextStyle()
                            } else {
                                Text("Failed to encode session")
                            }
                        }
                        Section("Local session") {
                            if let localSession, let jsonString = prettyJSONString(localSession) {
                                Text(jsonString)
                                    .supportingTextStyle()
                            } else {
                                Text("No local session")
                            }
                        }
                    }
                    .navigationTitle("Debug session")
                }
            })
            .task {
                guard !didAttemptE2EAutoLogin else { return }
                didAttemptE2EAutoLogin = true
                guard let token = E2EAutoLoginConfig.tokenFromLaunchArguments() else { return }
                await runAction(actionName: "E2E auto login") {
                    try await Auth.auth().signIn(withCustomToken: token)
                    _ = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
                }
            }
            .task {
                for await newSession in await apiClient.sessionChangedListener() {
                    localSession = newSession
                }
            }
            .background(Color.themeBlue)
            .cornerRadius(8)
            .foregroundStyle(Color.themeText)
        }
    }
}
#endif
