@testable import Domain
import Adapters
import ComposableArchitecture
import Foundation
import Testing

@MainActor
struct PresentableErrorTests {
    @Test func domainCodesUseDanishAndIgnoreServerMessages() {
        let cases: [(DomainCode, String, String)] = [
            (.feedbackAlreadySubmitted, "Feedback allerede sendt", "Du har allerede givet feedback på denne session."),
            (.eventAlreadyJoined, "Du har allerede deltaget", "Du har allerede tilmeldt dig denne session."),
            (.pincodeNotFound, "Ugyldig PIN-kode", "PIN-koden passer ikke til en aktiv session. Tjek koden, og prøv igen."),
            (.cannotJoinOwnEvent, "Ingen adgang", "Du kan ikke deltage i din egen session."),
            (.cannotGiveFeedbackToSelf, "Ingen adgang", "Du kan ikke give feedback til dig selv."),
            (.forbiddenResourceAccess, "Ingen adgang", "Du har ikke adgang til dette indhold.")
        ]
        for (code, title, message) in cases {
            let error = ApiError(
                timestamp: nil, message: "Internal English diagnostic", domainCode: code,
                exceptionType: "IllegalStateException", path: "/internal", statusCode: 500
            )
            #expect(error.localized == PresentableError(title: title, message: message))
        }
    }

    @Test func rawDescriptionsNeverBecomeCustomerCopy() {
        let errors: [any Error] = [
            NSError(domain: "TestDomain", code: 403, userInfo: [NSLocalizedDescriptionKey: "Secret English diagnostic"]),
            URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Internal URL"]),
            ApiError(timestamp: nil, message: "Raw server message", domainCode: nil, exceptionType: nil, path: nil),
            AppFailure.http(statusCode: 418)
        ]
        for error in errors {
            #expect(error.localized == PresentableError(title: "Der opstod en fejl", message: "Noget gik galt. Prøv igen."))
        }
    }

    @Test func networkErrorsHaveIntentionalRecoveryMessages() {
        #expect(URLError(.notConnectedToInternet).localized.message == "Tjek din internetforbindelse, og prøv igen.")
        #expect(URLError(.timedOut).localized.message == "Vi fik ikke svar i tide. Prøv igen.")
        #expect(URLError(.cannotConnectToHost).localized.message == "Vi kunne ikke oprette forbindelse. Prøv igen om lidt.")
        #expect(URLError(.userAuthenticationRequired).localized.message == "Du skal logge ind igen for at fortsætte.")
    }

    @Test func httpFailuresUseStatusWithoutRawMessages() {
        let cases: [(Int, String)] = [
            (401, "Du skal logge ind igen for at fortsætte."),
            (403, "Du har ikke adgang til dette indhold."),
            (404, "Indholdet findes ikke længere. Opdater, og prøv igen."),
            (408, "Vi fik ikke svar i tide. Prøv igen."),
            (409, "Indholdet er blevet ændret. Opdater, og prøv igen."),
            (429, "Der er for mange forsøg lige nu. Vent lidt, og prøv igen."),
            (503, "Der opstod en serverfejl. Prøv igen om lidt.")
        ]
        for (status, message) in cases {
            #expect(AppFailure.http(statusCode: status).localized.message == message)
        }
    }

    @Test func authenticationAndLocalFailuresAreLocalized() {
        #expect(AuthenticationError.loginCancelled.localized.message == "Login blev annulleret.")
        #expect(AuthenticationError.identityTokenMissing.localized.message == "Login kunne ikke gennemføres. Prøv igen.")
        #expect(AuthenticationError.notSignedIn.localized.title == "Log ind igen")
        #expect(AppFailure.inviteUnavailable.localized.message == "Invitationslinket kunne ikke oprettes. Prøv igen.")
        #expect(AppFailure.sessionUnavailable.localized.message == "Sessionen kunne ikke findes. Opdater, og prøv igen.")
        #expect(APIClientCache.CacheMutationError.activityNotFound(UUID()).localized.message ==
            "Visningen kunne ikke opdateres. Opdater siden for at hente de nyeste oplysninger.")
    }

    @Test func alertsUseLocalizedPresentationAndAction() {
        let alert = AlertState<Never>(error: URLError(.notConnectedToInternet))
        #expect(alert.title == TextState("Ingen internetforbindelse"))
        #expect(alert.message == TextState("Tjek din internetforbindelse, og prøv igen."))
        #expect(alert.buttons.first?.label == TextState("OK"))
    }
}
