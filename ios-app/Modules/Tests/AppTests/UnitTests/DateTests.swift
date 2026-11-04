import Testing
import Utility
import Foundation
import Localization

@MainActor
class DateTests {
    
    @Test
    func `Date rounds up correctly to nearest 5 minutes`() {
        let now = Date()
        let roundedDate = now.roundedUpcoming5Min()
        let expectedTime = Date(
            timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate / 300.0).rounded(.up) * 300.0
        )
        #expect(roundedDate == expectedTime)
    }
    
    @Test
    func `Date correctly identifies today`() {
        let date = Date()
        #expect(date.isToday == true)
    }
    
    @Test
    func `Date correctly identifies if after today`() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        #expect(tomorrow.isAfterToday == true)
    }
    
    @Test
    func `Date correctly identifies if before today`() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        #expect(yesterday.isBeforeToday == true)
    }
    
    @Test
    func `Date timeAgo returns correct localized string`() {
        let date = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        #expect(date.timeAgo(Locale(identifier: "en_US")) == "1 hour ago")
    }

    @Test
    func `Relative dates use an explicit reference instead of the live clock`() {
        let reference = Date(timeIntervalSince1970: 946_684_800)
        let locale = Locale(identifier: "en_US")
        #expect(reference.addingTimeInterval(-3600).timeAgo(locale, relativeTo: reference) == "1 hour ago")
        #expect(reference.addingTimeInterval(3600).timeAgo(locale, relativeTo: reference) == "in 1 hour")
    }

}

// Ordinary import verifies the generated interface is public across module boundaries.
struct GeneratedLocalizationTests {
    @Test func resolvesPlainAndParameterizedCopy() {
        #expect(String(appStrings: .commonSave) == "Gem")
        #expect(String(appStrings: .feedbackQuestionProgress(2, 5)) == "2 af 5")
        let invitation = String(appStrings: .sessionInviteMessage(
            "Weekly 100% sync", "0012", "https://example.com/invite/0012"
        ))
        #expect(invitation == """
        Du er inviteret til at give feedback på Weekly 100% sync.
        Brug PIN-kode 0012 for at svare.

        Åbn linket for at svare:
        https://example.com/invite/0012
        """)
    }

    @Test(arguments: [0, 1, 2])
    func choosesPluralForms(_ count: Int) {
        let noun = count == 1 ? "session" : "sessioner"
        #expect(String(appStrings: .activitySessionCount(count)) == "\(count) \(noun)")
        let responses = count == 1 ? "nyt feedbacksvar" : "nye feedbacksvar"
        #expect(String(appStrings: .notificationsReceivedFeedback(count, "Weekly 100% sync"))
            == "Du har modtaget \(count) \(responses) på ‘Weekly 100% sync’.")
    }

    @Test(arguments: [0, 1, 2])
    func comparisonPluralUsesSessionsRatherThanResponses(_ sessions: Int) {
        let noun = sessions == 1 ? "session" : "sessioner"
        for responses in [0, 1, 2, 42] {
            #expect(String(appStrings: .insightsComparison(sessions: sessions, responses))
                == "Sammenligner de seneste \(sessions) \(noun) med vurderinger · \(responses) vurderingssvar")
        }
    }

    @Test func resolvesBothSupportedLanguages() {
        var resource = LocalizedStringResource(appStrings: .commonSave)
        resource.locale = Locale(identifier: "en_US")
        #expect(String(localized: resource) == "Save")
        resource.locale = Locale(identifier: "da_DK")
        #expect(String(localized: resource) == "Gem")
    }

    @Test(arguments: [0, 1, 2, 99])
    func englishPluralsAndParameters(_ count: Int) {
        let noun = count == 1 ? "session" : "sessions"
        #expect(english(.activitySessionCount(count)) == "\(count) \(noun)")
        let response = count == 1 ? "response" : "responses"
        #expect(english(.notificationsReceivedFeedback(count, "Weekly 100% sync"))
            == "You have received \(count) new feedback \(response) for ‘Weekly 100% sync’.")
        for responses in [0, 1, 2, 42] {
            #expect(english(.insightsComparison(sessions: count, responses))
                == "Comparing the latest \(count) \(noun) with ratings · Ratings: \(responses)")
        }
    }

    @Test func englishInvitationsAndErrors() {
        #expect(english(.sessionInviteMessage("Weekly 100% sync", "0012", "https://example.com/invite/0012")) == """
        You are invited to give feedback on Weekly 100% sync.
        Use PIN code 0012 to respond.

        Open the link to respond:
        https://example.com/invite/0012
        """)
        #expect(english(.errorsOfflineTitle) == "No internet connection")
        #expect(english(.errorsGenericMessage) == "Something went wrong. Try again.")
        #expect(english(.templatesClearPurpose) == "Was the purpose clear?")
    }

    private func english(_ key: String.AppStrings) -> String {
        var resource = LocalizedStringResource(appStrings: key)
        resource.locale = Locale(identifier: "en_US")
        return String(localized: resource)
    }
}
