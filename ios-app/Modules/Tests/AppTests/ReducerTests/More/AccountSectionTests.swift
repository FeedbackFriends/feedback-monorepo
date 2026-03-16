@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct AccountSectionTests {

    @Test
    func `Settings button tap opens profile settings`() async {
        let session: Session = .mock()
        let store = TestStore(initialState: AccountSection.State(session: .init(value: session))) {
            AccountSection()
        }
        await store.send(.settingsButtonTap) {
            $0.destination = .profileSettings(
                ProfileSettings.State(
                    role: .manager,
                    accountInfo: session.accountInfo
                )
            )
        }
    }
    
    @Test
    func `Sign out button shows confirmation dialog and emits navigate delegate on confirmation`() async {
        let store = TestStore(
            initialState: AccountSection.State(
                session: .init(value: .mock())
            )
        ) {
            AccountSection()
        }
        
        await store.send(.signOutButtonTapped) {
            $0.destination = .confirmationDialog(
                .init(
                    title: { TextState("Logout") },
                    actions: {
                        ButtonState(role: .destructive, action: .logoutConfirmed, label: { TextState("Logout") })
                        ButtonState(label: { TextState("Cancel") })
                    },
                    message: { TextState("Are you sure you want to logout?") }
                )
            )
        }
        
        await store.send(.destination(.presented(.confirmationDialog(.logoutConfirmed)))) {
            $0.destination = nil
        }
        await store.receive(\.delegate, .navigateToSignUp)
    }
    
    @Test
    func `Delete account button emits delete account delegate`() async {
        let store = TestStore(
            initialState: AccountSection.State(
                session: .init(value: .mock())
            )
        ) {
            AccountSection()
        }
        
        await store.send(.deleteAccountButtonTapped)
        await store.receive(\.delegate, .deleteAccountButtonTapped)
    }
}
