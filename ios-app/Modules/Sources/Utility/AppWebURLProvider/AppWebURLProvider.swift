import Foundation

public struct AppWebURLProvider {

    public static func invite(forPinCode pinCode: String, baseUrl: URL) -> URL? {
        baseUrl
            .appendingPathComponent("invite")
            .appendingPathComponent(pinCode)
    }

    public static func privacyPolicy(forBaseUrl baseUrl: URL) -> URL {
        baseUrl.appendingPathComponent("privacy-policy/")
    }

    public static func appStoreReview(forAppStoreId appStoreId: String) -> URL {
        return URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review")!
    }
}
