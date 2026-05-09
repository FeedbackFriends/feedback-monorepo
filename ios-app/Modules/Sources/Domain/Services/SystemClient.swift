import ComposableArchitecture
import Foundation
#if canImport(UIKit)
import UIKit
#endif

private let openAppSettingsURLString: String = {
    #if canImport(UIKit)
    UIApplication.openSettingsURLString
    #else
    "app-settings:"
    #endif
}()

@DependencyClient
public struct SystemClient: Sendable {
    public var openAppSettings: @Sendable () async -> String = { openAppSettingsURLString }
    @DependencyEndpoint
    public var openEmail: @Sendable (_ subject: String, _ body: String) -> URL = { _, _ in return URL(string: "")! }
    public var privacyPolicyUrl: @Sendable () -> URL = { return URL(string: "")! }
    public var appStoreReviewUrl: @Sendable () -> URL = { return URL(string: "")! }
    public var webBaseUrl: @Sendable () -> URL = { return URL(string: "")! }
}
