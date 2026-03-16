import Foundation

public protocol AppConfig: Sendable {
    var apiBaseUrl: URL { get }
    var sentryDsnUrl: URL { get }
    var supportEmail: String { get }
    var webBaseUrl: URL { get }
    var appStoreId: String { get }
    var firebaseGoogleAppId: String { get }
    var firebaseGcmSenderId: String { get }
    var firebaseClientId: String { get }
    var firebaseApiKey: String { get }
    var firebaseBundleId: String { get }
    var firebaseProjectId: String { get }
    var firebaseStorageBucket: String { get }
    func logConfigurations()
}
