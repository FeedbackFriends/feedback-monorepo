@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Utility
import Domain

@MainActor
struct MoreSectionTests {
    
    @Test
    func `Notifications button opens app settings URL`() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(
            initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.systemClient.openAppSettings = {
                "settings_url"
            }
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
        }
        await store.send(.onNotificationsButtonTap)
        #expect(openedUrl.value?.absoluteString == "settings_url")
    }
    
    @Test
    func `Feedback button opens email composer with prefilled details`() async {
        let mockEmail = "mock@mock.dk"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.openURL = .init(handler: { url in
                openedUrl.setValue(url)
                return true
            })
            $0.systemClient.openEmail = { _, _ in
                var components = URLComponents(string: "mailto:mock@mock.dk")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: "mock"),
                    URLQueryItem(name: "body", value: "mock")
                ]
                return components.url!
            }
        }
        await store.send(.onFeedbackButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockEmail)") == true)
        #expect(openedUrl.value?.absoluteString.contains("mailto:mock@mock.dk") == true)
    }
    
    @Test
    func `Report bug button opens email composer with bug details`() async {
        let mockEmail = "mock@mock.dk"
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
            $0.systemClient.openEmail = { _, _ in
                var components = URLComponents(string: "mailto:mock@mock.dk")!
                components.queryItems = [
                    URLQueryItem(name: "subject", value: "mock"),
                    URLQueryItem(name: "body", value: "mock")
                ]
                return components.url!
            }
        }
        await store.send(.onReportBugButtonTap)
        #expect(openedUrl.value?.absoluteString.contains("mailto:\(mockEmail)") == true)
        #expect(openedUrl.value?.absoluteString.contains("subject=mock") == true)
        #expect(openedUrl.value?.absoluteString.contains("body=mock") == true)
    }
    
    @Test
    func `Support us button opens App Store review page`() async {
        let openedUrl = LockIsolated<URL?>(nil)
        let store = TestStore(
            initialState: MoreSection.State()) {
            MoreSection()
        } withDependencies: {
            $0.openURL = .init(handler: { @MainActor url in
                openedUrl.setValue(url)
                return true
            })
            $0.systemClient.appStoreReviewUrl = {
                URL(string: "https://apps.apple.com/app/id123456789?action=write-review")!
            }
        }
        await store.send(.onSupportUsButtonTap)
        #expect(openedUrl.value == URL(string: "https://apps.apple.com/app/id123456789?action=write-review")!)
    }
}
