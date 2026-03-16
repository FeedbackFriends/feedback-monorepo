import RootFeature
import SwiftUI
import Domain
import Foundation
import ComposableArchitecture
import DesignSystem
import Logger
import Utility
import TabbarFeature
import EventsFeature

@main
struct AppMockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootFeatureView(
                store: appDelegate.intialStore
            )
//            .task {
//                Task {
//                    try await Task.sleep(for: .seconds(1))
//                    await appDelegate.mockAuthEngine.yield(.authenticated)
//                }
//            }
        }
    }
}

actor MockAuthEngine {
    
    private var continuation: AsyncStream<UserState>.Continuation?
    
    func yield(_ state: UserState) {
        continuation?.yield(state)
    }
    
    func stream() -> AsyncStream<UserState> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
}

extension AuthClient {
    static func mock(mockAuthEngine: MockAuthEngine) -> Self {
        return Self.init(
            fetchCustomRole: { .manager },
            googleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            appleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            logout: {
                await mockAuthEngine.yield(.loggedOut)
            },
            userStateChanged: {
                await mockAuthEngine.stream()
            },
            signInWithCustomToken: { _ in }
        )
    }
}

public extension SystemClient {
    static func mock(
        supportEmail: String,
        webBaseUrl: URL,
        appStoreId: String
    ) -> SystemClient {
        return .init(
            openAppSettings: { UIApplication.openSettingsURLString },
            openEmail: { subject, body in
                var components = URLComponents(string: "mailto:\(supportEmail)")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: subject),
                    URLQueryItem(name: "body", value: body)
                ]
                return components.url!
            },
            privacyPolicyUrl: {
                return AppWebURLProvider.privacyPolicy(forBaseUrl: webBaseUrl)
            },
            appStoreReviewUrl: {
                return AppWebURLProvider.appStoreReview(forAppStoreId: appStoreId)
            },
            webBaseUrl: {
                return webBaseUrl
            }
        )
    }
}


extension NotificationClient {
    static let mock = Self.init(
        shouldPromptForAuthorization: { role in
//            if role == nil {
//                return false
//            }
//            let settings = await UNUserNotificationCenter.current().notificationSettings()
//            switch settings.authorizationStatus {
//            case .notDetermined:
//                return true
//            default:
//                return false
//            }
            return false
        },
        requestAuthorization: {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert,
                .badge,
                .sound
            ])
        },
        scheduleLocalNotification: { _, _, _, _, _ in },
        removeLocalPendingNotificationRequests: { _ in }
    )
}


final class AppDelegate: NSObject, UIApplicationDelegate {
    let mockAuthEngine = MockAuthEngine()
    let session = Shared(value: Session.mock())
    lazy var intialStore = Store(
        initialState: RootFeature.State(
            destination: .loggedIn(
                .init(
                    session: session,
                    selectedTab: .events
                )
            )
        ),
        reducer: {
            RootFeature()._printChanges()
        },
        withDependencies: {
            $0.apiClient = .mock
            $0.authClient = .mock(mockAuthEngine: self.mockAuthEngine)
            $0.systemClient = .mock(
                supportEmail: "nicolaidam96@gmail.com",
                webBaseUrl: URL(string: "https://letsgrow.dk")!,
                appStoreId: "123456789"
            )
            $0.notificationClient = .mock
        }
    )
    /// On app launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppTheme.setUp()
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        Logger.setup(
            logClients: [
                OSLogClient(subsystem: DeviceInfo().bundleIdentifier(), category: "LoggingClient")
            ]
        )
        intialStore.send(.onAppOpen)
        return true
    }
    
    /// When a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let deeplink = Deeplink(notificationUserInfo: response.notification.request.content.userInfo) else { return }
        intialStore.send(.onNotificationTap(deeplink))
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}
