import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(MessageUI)
import MessageUI
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
            },
            supportEmail: { supportEmail },
            canComposeMail: {
                #if canImport(MessageUI)
                return await MainActor.run { MFMailComposeViewController.canSendMail() }
                #else
                return false
                #endif
            },
            copyText: { text in
                #if canImport(UIKit)
                await MainActor.run { UIPasteboard.general.string = text }
                #endif
            },
            supportMetadata: {
                await MainActor.run {
                    let device = DeviceInfo()
                    return SupportClientMetadata(
                        appVersion: device.version(), appBuild: device.build(),
                        osVersion: device.operatingSystemVersion()
                    )
                }
            }
        )
    }
}
