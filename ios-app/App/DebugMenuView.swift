#if DEBUG
import ComposableArchitecture
import SwiftUI
import Domain
import FirebaseAuth
import FirebaseMessaging
import TabbarFeature
import DesignSystem
import Logger

extension Session: @retroactive Identifiable {
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

extension Session: @retroactive Encodable {
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

struct DebugMenuView: View {
    @State var debugMenuExpanded: Bool = false
    @State var hideDebugMenu: Bool = false
    @State var alert: String?
    @State var sessionSheet: Session?
    @State private var localSession: Session?
    let apiClient: APIClient
    let notificationClient: NotificationClient

    private func prettyJSONString<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
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
                                do {
                                    let session = try await apiClient.getSession()
                                    self.sessionSheet = session
                                } catch {
                                    Logger.debug(error.localizedDescription)
                                }
                            }
                        }
                        Button("Sign in with Mock") {
                            Task {
                                do {
                                    let mockToken = try await apiClient.getMockToken()
                                    Logger.debug("Mock token received: \n \(mockToken)")
                                    try await Auth.auth().signIn(withCustomToken: mockToken)
                                    Logger.debug("Signed in")
                                    _ = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
                                    Logger.debug("Succesful signin with mock token")
                                } catch {
                                    self.alert = error.localizedDescription
                                    Logger.debug(error.localizedDescription)
                                }
                            }
                        }
                        Button("Print id token") {
                            Task {
                                let token = try await Auth.auth().currentUser?.getIDToken()
                                Logger.debug(token ?? "Not found")
                            }
                        }
                        Button("Print fcm token") {
                            Task {
                                Logger.debug(Messaging.messaging().fcmToken ?? "Not found")
                            }
                        }
                        Button("Local mock notification") {
                            Task {
                                notificationClient.scheduleLocalNotification(
                                    title: "mock title",
                                    body: "mock body",
                                    userInfo: [:],
                                    presentAfterDelayInSeconds: 5,
                                    id: "mock_notification"
                                )
                            }
                        }
                        Button("Crash") {
                            fatalError("Debug crash")
                        }
                        Button("Logout") {
                            Task {
                                try Auth.auth().signOut()
                            }
                        }
                        Button("Hide") {
                            hideDebugMenu = true
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
                                    .font(.system(.body, design: .monospaced))
                            } else {
                                Text("Failed to encode session")
                            }
                        }
                        Section("Local session") {
                            if let localSession, let jsonString = prettyJSONString(localSession) {
                                Text(jsonString)
                                    .font(.system(.body, design: .monospaced))
                            } else {
                                Text("No local session")
                            }
                        }
                    }
                    .navigationTitle("Debug session")
                }
            })
            .task {
                for await newSession in await apiClient.sessionChangedListener() {
                    localSession = newSession
                }
            }
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundStyle(Color.themeText)
        }
    }
}
#endif
