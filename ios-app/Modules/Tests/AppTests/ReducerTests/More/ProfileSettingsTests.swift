@testable import MoreFeature
import Testing
import ComposableArchitecture
import Domain

@MainActor
struct ProfileSettingsTests {

    @Test
    func `Turning organizer mode off updates role and refreshes session`() async {
        let updatedRole = LockIsolated<Role?>(nil)
        let store = TestStore(
            initialState: ProfileSettings.State(
                role: .manager,
                accountInfo: .init(name: "Jane", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
            )
        ) {
            ProfileSettings()
        } withDependencies: {
            $0.apiClient.updateAccountRole = { role in
                updatedRole.setValue(role)
            }
        }

        await store.send(.organizerModeToggleChanged(false)) {
            $0.isOrganizerModeEnabled = false
            $0.isLoading = true
        }
        await store.receive(\.updateAccountRoleResponse, .participant) {
            $0.isLoading = false
            $0.persistedRole = .participant
        }
        await store.receive(\.delegate, .refreshSession)
        #expect(updatedRole.value == .participant)
    }

    @Test
    func `Turning organizer mode off reverts toggle on failure`() async {
        struct Failure: Error, Equatable {}

        let store = TestStore(
            initialState: ProfileSettings.State(
                role: .manager,
                accountInfo: .init(name: "Jane", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
            )
        ) {
            ProfileSettings()
        } withDependencies: {
            $0.apiClient.updateAccountRole = { _ in throw Failure() }
        }

        await store.send(.organizerModeToggleChanged(false)) {
            $0.isOrganizerModeEnabled = false
            $0.isLoading = true
        }
        await store.receive(\.presentError) {
            $0.isLoading = false
            $0.isOrganizerModeEnabled = true
            $0.destination = .alert(.init(error: Failure()))
        }
    }

    @Test
    func `Update profile button tap opens modify account`() async {
        let store = TestStore(
            initialState: ProfileSettings.State(
                role: .manager,
                accountInfo: .init(name: "Jane", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
            )
        ) {
            ProfileSettings()
        }

        await store.send(.updateProfileButtonTap) {
            $0.destination = .modifyAccount(
                .init(
                    nameInput: "Jane",
                    emailInput: "jane@doe.com",
                    phoneNumberInput: "+45 12 34 56 78"
                )
            )
        }
    }

    @Test
    func `Email events toggle only updates local state`() async {
        let store = TestStore(
            initialState: ProfileSettings.State(
                role: .manager,
                accountInfo: .init(name: "Jane", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
            )
        ) {
            ProfileSettings()
        }

        await store.send(.emailEventsToggleChanged(true)) {
            $0.isEmailEventsEnabled = true
        }
    }

    @Test
    func `In-app notifications toggle only updates local state`() async {
        let store = TestStore(
            initialState: ProfileSettings.State(
                role: .manager,
                accountInfo: .init(name: "Jane", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
            )
        ) {
            ProfileSettings()
        }

        await store.send(.inAppNotificationsToggleChanged(true)) {
            $0.isInAppNotificationsEnabled = true
        }
    }
}
