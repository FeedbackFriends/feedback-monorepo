@testable import SignUpFeature
import ComposableArchitecture
import Testing

@MainActor
struct SignUpNotificationPermissionPromptTests {

    @Test
    func `Enable push notifications starts submission requests auth and completes`() async {
        let notificationAuthorizationRequested = LockIsolated(false)
        let store = TestStore(initialState: NotificationPermissionPrompt.State()) {
            NotificationPermissionPrompt()
        } withDependencies: {
            $0.notificationClient.requestAuthorization = { @Sendable in
                notificationAuthorizationRequested.setValue(true)
                return true
            }
        }

        await store.send(.enablePushNotificationsButtonTap) {
            $0.isSubmitting = true
        }
        await store.receive(\.delegate, .completed)
        #expect(notificationAuthorizationRequested.value == true)
    }

    @Test
    func `Enable emails starts submission and completes without requesting auth`() async {
        let notificationAuthorizationRequested = LockIsolated(false)
        let store = TestStore(initialState: NotificationPermissionPrompt.State()) {
            NotificationPermissionPrompt()
        } withDependencies: {
            $0.notificationClient.requestAuthorization = { @Sendable in
                notificationAuthorizationRequested.setValue(true)
                return true
            }
        }

        await store.send(.enableEmailsButtonTap) {
            $0.isSubmitting = true
        }
        await store.receive(\.delegate, .completed)
        #expect(notificationAuthorizationRequested.value == false)
    }
}
