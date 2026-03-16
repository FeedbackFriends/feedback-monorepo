import Foundation
import UIKit
import Domain
import Utility

public extension SystemClient {
    static func live(
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
