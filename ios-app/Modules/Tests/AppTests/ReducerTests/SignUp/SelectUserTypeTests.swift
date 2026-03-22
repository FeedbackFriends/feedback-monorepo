@testable import SignUpFeature
import Testing
import ComposableArchitecture
import Domain

struct SelectUserTypeTests {
    enum TestError: Error, Equatable { case mock }

    @Test
    func `Create account succeeds and navigates to session fetch`() async {
        let store = await TestStore(initialState: SelectUserType.State()) {
            SelectUserType()
        } withDependencies: {
            $0.apiClient.createAccount = { _ in
                    .mock()
            }
        }

        await store.send(\.binding.selectedUserType, .manager) {
            $0.selectedUserType = .manager
        }

        await store.send(.createAccountButtonTap) {
            $0.isLoading = true
        }

        await store.receive(\.delegate, .getSession)
    }

    @Test
    func `Create account fails and shows error alert`() async {
        let store = await TestStore(initialState: SelectUserType.State()) {
            SelectUserType()
        } withDependencies: {
            $0.apiClient.createAccount = { _ in throw TestError.mock }
        }

        await store.send(\.binding.selectedUserType, .manager) {
            $0.selectedUserType = .manager
        }

        await store.send(.createAccountButtonTap) {
            $0.isLoading = true
        }

        await store.receive(\.presentError) {
            $0.isLoading = false
            $0.destination = .alert(.init(error: TestError.mock))
        }
    }

    @Test
    func `Create account button is disabled when no user type is selected`() {
        let state = SelectUserType.State()
        #expect(state.disableUserTypeSelectionButton)
    }

    @Test
    func `Create account button is enabled when user type is selected`() {
        var state = SelectUserType.State()
        state.selectedUserType = .manager
        #expect(!state.disableUserTypeSelectionButton)
    }
}
