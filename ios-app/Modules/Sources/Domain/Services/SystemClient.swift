import ComposableArchitecture
import Foundation
import UIKit

@DependencyClient
public struct SystemClient: Sendable {
    public var openAppSettings: @Sendable () async -> String = { UIApplication.openSettingsURLString }
    @DependencyEndpoint
    public var openEmail: @Sendable (_ subject: String, _ body: String) -> URL = { _, _ in return URL(string: "")! }
    public var privacyPolicyUrl: @Sendable () -> URL = { return URL(string: "")! }
    public var appStoreReviewUrl: @Sendable () -> URL = { return URL(string: "")! }
    public var webBaseUrl: @Sendable () -> URL = { return URL(string: "")! }
}
