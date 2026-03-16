@testable import Domain
import Foundation
import Testing

@MainActor
struct PresentableErrorTests {
    @Test func `Presentable error correctly handles URL errors`() async throws {
        let urlError = URLError(.badURL)
        let presentableError = urlError.localized
        #expect(presentableError.title == "Error 💩")
        #expect(presentableError.message == urlError.localizedDescription)
    }
    @Test func `Presentable error correctly maps API feedbackAlreadySubmitted error`() async throws {
        let apiError = ApiError(domainCode: .feedbackAlreadySubmitted)
        let presentableError = apiError.localized
        #expect(presentableError.title == "Duplicate feedback")
        #expect(presentableError.message == "Feedback already submitted for this event.")
    }
    
    @Test func `Presentable error correctly displays generic NSError messages`() async throws {
        let genericError = NSError(domain: "TestDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "A generic error occurred."])
        let presentableError = genericError.localized
        #expect(presentableError.title == "Error 💩")
        #expect(presentableError.message == "A generic error occurred.")
    }
    
    @Test func `Presentable error correctly handles login flow cancelled case`() async throws {
        let loginFlowCancelledError = AuthenticationError.loginCancelled
        let presentableError = loginFlowCancelledError.localized
        #expect(presentableError.title == "Error 💩")
        #expect(presentableError.message == "An unexpected issue occurred. Try again.")
    }
    
    @Test func `Presentable error correctly maps API eventAlreadyJoined error`() async throws {
        let apiError = ApiError(domainCode: .eventAlreadyJoined)
        let presentableError = apiError.localized
        #expect(presentableError.title == "Already joined")
        #expect(presentableError.message == "You already joined this event.")
    }
}

extension ApiError {
    init (domainCode: DomainCode) {
        self.init(
            timestamp: nil,
            message: nil,
            domainCode: domainCode,
            exceptionType: nil,
            path: nil
        )
    }
}
