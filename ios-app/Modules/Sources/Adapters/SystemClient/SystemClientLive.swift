import Foundation
#if canImport(UIKit)
import UIKit
#endif
import Domain
import Utility

private let openSettingsURLString: String = {
    #if canImport(UIKit)
    UIApplication.openSettingsURLString
    #else
    "app-settings:"
    #endif
}()

public extension SystemClient {
    static func live(
        supportEmail: String,
        webBaseUrl: URL,
        appStoreId: String
    ) -> SystemClient {
        return .init(
            openAppSettings: { openSettingsURLString },
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
