@testable import SignUpFeature
import Testing
import ComposableArchitecture
import Domain
import Foundation
import Localization

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
    @Test
    func emailCodeResendWaitAndSuccessfulVerification() async {
        let now = Date(timeIntervalSince1970: 1_000)
        var initial = SignUp.State()
        initial.email = " ADA@example.com "
        let store = await TestStore(initialState: initial) { SignUp() } withDependencies: {
            $0.date.now = now
            $0.authClient.sendEmailCode = { email in #expect(email == "ada@example.com") }
            $0.authClient.verifyEmailCode = { email, code in
                #expect(email == "ada@example.com")
                #expect(code == "123456")
            }
        }
        await store.send(.emailContinueTap) { $0.emailLoginInFlight = true }
        await store.receive(\.emailCodeSent) {
            $0.emailLoginInFlight = false
            $0.emailCodeSent = true
            $0.emailResendAt = now.addingTimeInterval(60)
            $0.emailStatus = String(appStrings: .signInCodeSent)
        }
        await store.send(.emailResendTap) { $0.emailStatus = String(appStrings: .signInResendWait) }
        await store.send(.binding(.set(\.emailCode, " 123456 "))) { $0.emailCode = " 123456 " }
        await store.send(.emailContinueTap) {
            $0.emailLoginInFlight = true
            $0.emailStatus = nil
        }
        await store.receive(\.signUpSuccess) { $0.emailLoginInFlight = false }
    }

    @Test
    func emailCodeFailureRetainsAddressAndAllowsChangingIt() async {
        var initial = SignUp.State()
        initial.email = "ada@example.com"
        initial.emailCodeSent = true
        initial.emailCode = "000000"
        let store = await TestStore(initialState: initial) { SignUp() } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 1_000)
            $0.authClient.verifyEmailCode = { _, _ in throw TestError.mock }
        }
        await store.send(.emailContinueTap) { $0.emailLoginInFlight = true }
        await store.receive(\.emailFailed) {
            $0.emailLoginInFlight = false
            $0.emailStatus = String(appStrings: .signInCodeFailed)
        }
        await store.send(.emailChangeTap) {
            $0.emailCodeSent = false
            $0.emailCode = ""
            $0.emailStatus = nil
        }
    }

    @Test
    func emailSubmissionCannotOverlapAnotherProvider() async {
        var initial = SignUp.State(googleLoginInFlight: true)
        initial.email = "ada@example.com"
        let store = await TestStore(initialState: initial) { SignUp() }
        await store.send(.emailContinueTap)
        await store.send(.emailResendTap)
        await store.send(.signUpWithAppleButtonTap)
    }

}
