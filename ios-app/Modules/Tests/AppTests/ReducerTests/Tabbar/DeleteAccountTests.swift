@testable import TabbarFeature
import ComposableArchitecture
import Testing
import Foundation
import Domain

@MainActor
struct DeleteAccountTests {

    @Test
    func `Delete account confirmation completes successfully and shows success alert`() async {
        let store = TestStore(initialState: .init()) {
            DeleteAccount()
        } withDependencies: {
            $0.apiClient.deleteAccount = { () }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.deleteAccountButtonTapped) {
            $0.destination = .alert(
                AlertState(
                    title: { TextState("Vil du slette din konto?") },
                    actions: {
                        ButtonState(role: .destructive, action: .confirmedToDeleteAccount, label: { TextState("Slet konto") })
                        ButtonState(role: .cancel, label: { TextState("Annuller") })
                    },
                    message: { TextState("Alle data på din konto bliver slettet og kan ikke gendannes.") }
                )
            )
        }

        await store.send(.destination(.presented(.alert(.confirmedToDeleteAccount)))) {
            $0.deleteAccountInFlight = true
            $0.destination = nil
        }

        await store.receive(\.accountSuccesfullyDeleted) {
            $0.deleteAccountInFlight = false
            $0.destination = .alert(
                AlertState(
                    title: { TextState("Kontoen er slettet") },
                    actions: {
                        ButtonState(role: .cancel, action: .send(.closeSessionButtonTap), label: { TextState("Luk") })
                    },
                    message: { TextState("Tak, fordi du brugte LetsGrow.") }
                )
            )
        }
    }

    @Test
    func `Delete account failure presents error alert`() async {
        let error = URLError(.cannotConnectToHost)
        let store = TestStore(initialState: .init()) {
            DeleteAccount()
        } withDependencies: {
            $0.apiClient.deleteAccount = { throw error }
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.deleteAccountButtonTapped) {
            $0.destination = .alert(
                .init(
                    title: { TextState("Vil du slette din konto?") },
                    actions: {
                        ButtonState(
                            role: .destructive,
                            action: .confirmedToDeleteAccount,
                            label: { TextState("Slet konto") }
                        )
                        ButtonState(
                            role: .cancel,
                            label: { TextState("Annuller") }
                        )
                    },
                    message: { TextState("Alle data på din konto bliver slettet og kan ikke gendannes.") }
                )
            )
        }
        await store.send(.destination(.presented(.alert(.confirmedToDeleteAccount)))) {
            $0.deleteAccountInFlight = true
            $0.destination = nil
        }

        await store.receive(\.presentError) {
            $0.deleteAccountInFlight = false
            $0.destination = .alert(.init(error: error))
        }
    }

    @Test
    func `Logout failure shows retry alert`() async {
        let store = TestStore(initialState: .init(
            destination: .alert(AlertState(title: { TextState("Kontoen er slettet") }))
        )) {
            DeleteAccount()
        } withDependencies: {
            $0.authClient.logout = { throw URLError(.timedOut) }
        }

        await store.send(.destination(.presented(.alert(.closeSessionButtonTap)))) {
            $0.destination = nil
        }
        await store.receive(\.logoutFailed) {
            $0.destination = .alert(
                AlertState(
                    title: { TextState("Kunne ikke logge ud") },
                    actions: {
                        ButtonState(action: .send(.logout), label: { TextState("Log ud") })
                    },
                    message: { TextState("Prøv igen.") }
                )
            )
        }
    }

    @Test
    func `Logout retry succeeds and closes session`() async {
        let store = TestStore(initialState: .init(
            destination: .alert(AlertState(title: { TextState("Kunne ikke logge ud") }))
        )) {
            DeleteAccount()
        } withDependencies: {
            $0.authClient.logout = { /* success */ }
        }
        
        await store.send(.destination(.presented(.alert(.logout)))) {
            $0.destination = nil
        }
        // No follow-up receive
        // Navigation happens automatically from RootFeature where stream is triggered by firebase
    }
}
