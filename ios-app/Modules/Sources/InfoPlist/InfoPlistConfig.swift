import Logger
import Foundation
import Domain

public struct InfoPlistConfig: AppConfig {
    
    public init() {}
    
    public var apiBaseUrl: URL {
        InfoPlistReader().url(for: "API_BASE_URL", scheme: "API_SCHEME")!
    }
    public var sentryDsnUrl: URL {
        InfoPlistReader().url(for: "SENTRY_DSN_URL", scheme: "SENTRY_DSN_SCHEME")!
    }
    public var supportEmail: String {
        InfoPlistReader().string(for: "SUPPORT_EMAIL")!
    }
    public var webBaseUrl: URL {
        InfoPlistReader().url(for: "WEB_BASE_URL", scheme: "WEB_SCHEME")!
    }
    public var appStoreId: String {
        InfoPlistReader().string(for: "APPSTORE_ID")!
    }
    public var firebaseGoogleAppId: String {
        InfoPlistReader().string(for: "FIREBASE_GOOGLE_APP_ID")!
    }
    public var firebaseGcmSenderId: String {
        InfoPlistReader().string(for: "FIREBASE_GCM_SENDER_ID")!
    }
    public var firebaseClientId: String {
        InfoPlistReader().string(for: "FIREBASE_CLIENT_ID")!
    }
    public var firebaseApiKey: String {
        InfoPlistReader().string(for: "FIREBASE_API_KEY")!
    }
    public var firebaseBundleId: String {
        InfoPlistReader().string(for: "FIREBASE_BUNDLE_ID")!
    }
    public var firebaseProjectId: String {
        InfoPlistReader().string(for: "FIREBASE_PROJECT_ID")!
    }
    public var firebaseStorageBucket: String {
        InfoPlistReader().string(for: "FIREBASE_STORAGE_BUCKET")!
    }

    public func logConfigurations() {
        Logger.debug(
            """
            🔹 API_BASE_URL: \(self.apiBaseUrl)\n
            🔹 SENTRY_DSN_URL: \(self.sentryDsnUrl)\n
            🔹 SUPPORT_EMAIL: \(self.supportEmail)\n
            🔹 WEB_BASE_URL: \(self.webBaseUrl)\n
            🔹 APPSTORE_ID: \(self.appStoreId)\n
            🔹 FIREBASE_GOOGLE_APP_ID: \(self.firebaseGoogleAppId)\n
            🔹 FIREBASE_GCM_SENDER_ID: \(self.firebaseGcmSenderId)\n
            🔹 FIREBASE_CLIENT_ID: \(self.firebaseClientId)\n
            🔹 FIREBASE_API_KEY: \(self.firebaseApiKey)\n
            🔹 FIREBASE_BUNDLE_ID: \(self.firebaseBundleId)\n
            🔹 FIREBASE_PROJECT_ID: \(self.firebaseProjectId)\n
            🔹 FIREBASE_STORAGE_BUCKET: \(self.firebaseStorageBucket)
            """
        )
    }
}
