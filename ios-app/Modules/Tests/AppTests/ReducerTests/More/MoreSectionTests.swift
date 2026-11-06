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
    func feedbackAndBugButtonsOpenIndependentInAppForms() async {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000123")!
        let feedback = TestStore(initialState: MoreSection.State()) { MoreSection() } withDependencies: {
            $0.uuid = .constant(id)
        }
        await feedback.send(.onFeedbackButtonTap) {
            $0.productContact = .init(kind: .productFeedback, submissionID: id)
        }
        await feedback.send(.onFeedbackButtonTap)
        await feedback.send(.onReportBugButtonTap)
        let bug = TestStore(initialState: MoreSection.State()) { MoreSection() } withDependencies: {
            $0.uuid = .constant(id)
        }
        await bug.send(.onReportBugButtonTap) {
            $0.productContact = .init(kind: .bugReport, submissionID: id)
        }
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
