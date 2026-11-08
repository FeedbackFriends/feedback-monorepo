import ComposableArchitecture
import Foundation

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient()
    public static var previewValue: Self {
        actor MockAuthEngine {
            private var continuation: AsyncStream<UserState>.Continuation?
            func yield(_ state: UserState) {
                continuation?.yield(state)
            }
            func stream() -> AsyncStream<UserState> {
                AsyncStream { continuation in
                    self.continuation = continuation
                }
            }
        }
        let mockAuthEngine = MockAuthEngine()
        return Self.init(
            signInAnonymously: {
                await mockAuthEngine.yield(.anonymous)
            },
            googleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            appleLogin: {
                await mockAuthEngine.yield(.authenticated)
            },
            logout: {
                await mockAuthEngine.yield(.loggedOut)
            },
            userStateChanged: {
                await mockAuthEngine.stream()
            },
            restoreTestSession: { _ in },
            sendEmailCode: { _ in },
            verifyEmailCode: { _, _ in await mockAuthEngine.yield(.authenticated) }
        )
    }
}
