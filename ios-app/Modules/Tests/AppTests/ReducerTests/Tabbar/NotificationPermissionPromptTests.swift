@testable import TabbarFeature
import ComposableArchitecture
import Testing
@testable import Domain

@MainActor
struct NotificationPermissionPromptTests {

    @Test
    func `Enable push notifications starts submission requests auth and dismisses`() async {
        let didDismiss = LockIsolated(false)
        let notificationAuthorizationRequested = LockIsolated(false)
        let store = TestStore(initialState: NotificationPermissionPrompt.State()) {
            NotificationPermissionPrompt()
        } withDependencies: {
            $0.dismiss = .init {
                didDismiss.setValue(true)
            }
            $0.notificationClient.requestAuthorization = { @Sendable in
                notificationAuthorizationRequested.setValue(true)
                return true
            }
        }

        await store.send(.enablePushNotificationsButtonTap) {
            $0.isSubmitting = true
        }
        #expect(didDismiss.value == true)
        #expect(notificationAuthorizationRequested.value == true)
    }

    @Test
    func `Enable emails starts submission and dismisses without requesting auth`() async {
        let didDismiss = LockIsolated(false)
        let notificationAuthorizationRequested = LockIsolated(false)
        let store = TestStore(initialState: NotificationPermissionPrompt.State()) {
            NotificationPermissionPrompt()
        } withDependencies: {
            $0.dismiss = .init {
                didDismiss.setValue(true)
            }
            $0.notificationClient.requestAuthorization = { @Sendable in
                notificationAuthorizationRequested.setValue(true)
                return true
            }
        }

        await store.send(.enableEmailsButtonTap) {
            $0.isSubmitting = true
        }
        #expect(didDismiss.value == true)
        #expect(notificationAuthorizationRequested.value == false)
    }
}
