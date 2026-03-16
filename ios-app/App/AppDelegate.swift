import ComposableArchitecture
import Domain
import RootFeature
import FirebaseAuth
import FirebaseCore
import FirebasePerformance
import FirebaseMessaging
import FirebaseCrashlytics
import DesignSystem
import UIKit
import Logger
import Adapters
import Utility
import OpenAPI
import OpenAPIURLSession
import OpenAPIRuntime
import InfoPlist
import Sentry

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    var apiClient: APIClient = .live(
        client: Client(
            serverURL: InfoPlistConfig().apiBaseUrl,
            configuration: Configuration(),
            transport: URLSessionTransport(),
            middlewares: [
                AuthorisationMiddleware(),
                DelayMiddleware(),
                DeviceIdHeaderMiddleware(deviceId: DeviceInfo().deviceID())
            ]
        ),
        provideFcmToken: {
            try? await Messaging.messaging().token()
        }
    )
    var notificationClient: NotificationClient = .live
    
    lazy var intialStore = Store(
        initialState: RootFeature.State()
    ) {
        RootFeature()._printChanges()
    } withDependencies: {
        $0.systemClient = .live(
            supportEmail: InfoPlistConfig().supportEmail,
            webBaseUrl: InfoPlistConfig().webBaseUrl,
            appStoreId: InfoPlistConfig().appStoreId
        )
        $0.notificationClient = self.notificationClient
        $0.authClient = .live
        $0.apiClient = self.apiClient
    }
    
    var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// On app launch
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Logger.setup(
            logClients: [
                CrashlyticsLoggingClient.create(deviceId: DeviceInfo().deviceID(), minLevel: .error),
                SentryLoggingClient.create(deviceId: DeviceInfo().deviceID(), minLevel: .error),
                OSLogClient(subsystem: DeviceInfo().bundleIdentifier(), category: "LoggingClient")
            ]
        )
        InfoPlistConfig().logConfigurations()
        SentrySDK.start { options in
            options.dsn = InfoPlistConfig().sentryDsnUrl.absoluteString
            options.debug = self.isDebug
            options.tracesSampleRate = 1.0
            options.tracePropagationTargets = [
                InfoPlistConfig().apiBaseUrl.absoluteString
            ]
            options.releaseName = "\(DeviceInfo().version())(\(String(describing: DeviceInfo().build)))"
        }
        let firebaseOptions = FirebaseOptions(
            googleAppID: InfoPlistConfig().firebaseGoogleAppId,
            gcmSenderID: InfoPlistConfig().firebaseGcmSenderId
        )
        firebaseOptions.clientID = InfoPlistConfig().firebaseClientId
        firebaseOptions.apiKey = InfoPlistConfig().firebaseApiKey
        firebaseOptions.bundleID = InfoPlistConfig().firebaseBundleId
        firebaseOptions.projectID = InfoPlistConfig().firebaseProjectId
        firebaseOptions.storageBucket = InfoPlistConfig().firebaseStorageBucket
        FirebaseApp.configure(options: firebaseOptions)
        AppTheme.setUp()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        intialStore.send(.onAppOpen)
        return true
    }
    
    /// When a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let deeplink = Deeplink(notificationUserInfo: response.notification.request.content.userInfo) else { return }
        intialStore.send(.onNotificationTap(deeplink))
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        intialStore.send(.didReceiveFCMToken(fcmToken))
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
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
