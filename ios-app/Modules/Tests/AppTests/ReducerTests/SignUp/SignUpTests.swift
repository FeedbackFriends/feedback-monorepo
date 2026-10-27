@testable import SignUpFeature
import Testing
import ComposableArchitecture
import Domain

struct SignUpTests {
    enum TestError: Error, Equatable { case mock }
    
    @Test
    func `Sign up with Apple succeeds and updates state correctly`() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.appleLogin = { () }
        }

        await store.send(.signUpWithAppleButtonTap) {
            $0.appleLoginInFlight = true
        }
        await store.receive(\.signUpSuccess) {
            $0.appleLoginInFlight = false
        }
    }

    @Test
    func `Sign up with Google succeeds and updates state correctly`() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.googleLogin = { () }
        }

        await store.send(.signUpWithGoogleButtonTap) {
            $0.googleLoginInFlight = true
        }
        await store.receive(\.signUpSuccess) {
            $0.googleLoginInFlight = false
        }
    }

    @Test
    func `Sign up with Apple is cancelled and resets state`() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.appleLogin = { throw AuthenticationError.loginCancelled }
        }
        await store.send(.signUpWithAppleButtonTap) {
            $0.appleLoginInFlight = true
        }
        await store.receive(\.loginCancelled) {
            $0.appleLoginInFlight = false
        }
    }

    @Test
    func `Sign up with Google is cancelled and resets state`() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.googleLogin = { throw AuthenticationError.loginCancelled }
        }

        await store.send(.signUpWithGoogleButtonTap) {
            $0.googleLoginInFlight = true
        }
        await store.receive(\.loginCancelled) {
            $0.googleLoginInFlight = false
        }
    }

    @Test
    func `Sign up with Apple fails and presents error alert`() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.appleLogin = { throw TestError.mock }
        }

        await store.send(.signUpWithAppleButtonTap) {
            $0.appleLoginInFlight = true
        }
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: TestError.mock))
            $0.appleLoginInFlight = false
        }
    }

    @Test
    func `Sign up with Google fails and presents error alert`() async {
        let store = await TestStore(initialState: SignUp.State()) {
            SignUp()
        } withDependencies: {
            $0.authClient.googleLogin = { throw TestError.mock }
        }

        await store.send(.signUpWithGoogleButtonTap) {
            $0.googleLoginInFlight = true
        }
        await store.receive(\.presentError) {
            $0.destination = .alert(.init(error: TestError.mock))
            $0.googleLoginInFlight = false
        }
    }
}
