@testable import Localization
import Foundation
import Testing

struct LocalizationTests {
    @Test(arguments: [
        (["en-US"], "en"), (["en-GB"], "en"), (["da-DK"], "da"),
        (["fr", "en"], "en"), (["da", "en"], "da"), (["en", "da"], "en")
    ])
    func nativeResourcesSelectSupportedLanguage(_ preferences: [String], _ expected: String) {
        let localizations = Bundle.preferredLocalizations(
            from: L10n.resourceBundle.localizations,
            forPreferences: preferences
        )
        #expect(localizations.first == expected)
    }

    @Test func resolvesModuleResources() {
        #expect(String(appStrings: .commonSave) == "Gem")
        #expect(String(appStrings: .commonCancel) == "Annuller")
        #expect(L10n.resourceBundle.developmentLocalization == "da")
        #expect(L10n.locale.language.languageCode?.identifier == "da")
    }

    @Test func choosesPluralForms() {
        #expect(String(appStrings: .activitySessionCount(0)) == "0 sessioner")
        #expect(String(appStrings: .activitySessionCount(1)) == "1 session")
        #expect(String(appStrings: .activitySessionCount(2)) == "2 sessioner")
    }

    @Test func preservesParametersVerbatim() {
        #expect(String(appStrings: .feedbackQuestionProgress(2, 5)) == "2 af 5")
        let text = String(appStrings: .sessionInviteMessage("Weekly 100% sync", "0012", "https://example.com/invite/0012"))
        #expect(text == """
        Du er inviteret til at give feedback på Weekly 100% sync.
        Brug PIN-kode 0012 for at svare.

        Åbn linket for at svare:
        https://example.com/invite/0012
        """)
    }

    @Test func usesDanishNumbersAndDurations() {
        #expect(L10n.Format.number(4.5) == "4,5")
        #expect(L10n.Format.percent(0.425, fractionDigits: 1).contains("42,5"))
        #expect(L10n.Format.duration(minutes: 60) == "1 time")
        #expect(L10n.Format.duration(minutes: 120) == "2 timer")
        #expect(L10n.Format.duration(minutes: 0).contains("0"))
        #expect(L10n.Format.duration(minutes: 90).contains("30"))
    }

    @Test func preservesRequestedTimeZone() throws {
        let instant = Date(timeIntervalSince1970: 1_735_732_800)
        let utc = try #require(TimeZone(secondsFromGMT: 0))
        let copenhagen = try #require(TimeZone(identifier: "Europe/Copenhagen"))
        #expect(L10n.Format.date(instant, date: .omitted, time: .shortened, timeZone: utc) == "12.00")
        #expect(L10n.Format.date(instant, date: .omitted, time: .shortened, timeZone: copenhagen) == "13.00")
        #expect(L10n.Format.relativeTime(instant.addingTimeInterval(-3600), relativeTo: instant) == "for 1 time siden")
        #expect(L10n.Format.relativeTime(instant.addingTimeInterval(3600), relativeTo: instant) == "om 1 time")
        let interval = L10n.Format.interval(from: instant, to: instant.addingTimeInterval(3600), timeZone: copenhagen)
        #expect(interval.contains("13.00"))
        #expect(interval.contains("14.00"))
    }

    @Test func dynamicCopyUsesDanishGrammarAndPreservesUserContent() {
        #expect(String(appStrings: .sessionHourCount(0)) == "0 timer")
        #expect(String(appStrings: .sessionHourCount(1)) == "1 time")
        #expect(String(appStrings: .sessionHourCount(2)) == "2 timer")
        #expect(String(appStrings: .feedbackNewResponses(1)) == "1 nyt svar")
        #expect(String(appStrings: .feedbackNewResponses(2)) == "2 nye svar")
        #expect(String(appStrings: .notificationsReceivedFeedback(1, "Weekly 100% sync"))
            == "Du har modtaget 1 nyt feedbacksvar på ‘Weekly 100% sync’.")
        #expect(String(appStrings: .notificationsReceivedFeedback(2, "Weekly 100% sync"))
            == "Du har modtaget 2 nye feedbacksvar på ‘Weekly 100% sync’.")
        #expect(String(appStrings: .moreEmailBody("iPhone 100%"))
            == "<Skriv din besked her>\n\nEnhedsoplysninger\niPhone 100%")
        #expect(String(appStrings: .insightsScoreValue(L10n.Format.number(4.5))) == "4,5 / 5")
        #expect(String(appStrings: .commonUnknown) == "Ukendt")
        #expect(String(appStrings: .supportDeviceDetails("Phone", "iPhone", "iOS", "27", "ID"))
            == "Enhed:\nNavn: Phone\nModel: iPhone\nSystem: iOS 27\nEnheds-id: ID")
        #expect(String(appStrings: .supportAppDetails("LetsGrow", "1.2", "3", "app.id"))
            == "App:\nNavn: LetsGrow\nVersion: 1.2\nBuild: 3\nBundle-id: app.id")
    }

    @Test func sessionIntervalsIncludeBothDaysAndTheCorrectStartTime() throws {
        let utc = try #require(TimeZone(secondsFromGMT: 0))
        // 1 January 2025, 23:00 UTC; ends on 2 January at 01:00.
        let start = Date(timeIntervalSince1970: 1_735_772_400)
        let result = L10n.Format.sessionDate(start: start, durationMinutes: 120, timeZone: utc)
        #expect(result.contains("23.00"))
        #expect(result.contains("01.00"))
        #expect(result.contains("1."))
        #expect(result.contains("2."))
        #expect(!result.contains(" at "))
        #expect(!result.contains(" to "))
        let allDay = L10n.Format.sessionDate(start: start, durationMinutes: 1440, timeZone: utc)
        #expect(allDay.contains("Hele dagen"))
        #expect(!allDay.contains("23.00"))
    }
    @Test func nativeGeneratedSymbolsResolvePlainParameterizedAndPluralCopy() {
        #expect(String(localized: .AppStrings.commonSave) == "Gem")
        #expect(String(localized: .AppStrings.activitySessionCount(0)) == "0 sessioner")
        #expect(String(localized: .AppStrings.activitySessionCount(1)) == "1 session")
        #expect(String(localized: .AppStrings.activitySessionCount(2)) == "2 sessioner")
        #expect(String(localized: .AppStrings.feedbackQuestionProgress(2, 5)) == "2 af 5")
        let invitation = String(localized: .AppStrings.sessionInviteMessage(
            "Weekly 100% sync", "0012", "https://example.com/invite/0012"
        ))
        #expect(invitation == String(appStrings: .sessionInviteMessage("Weekly 100% sync", "0012", "https://example.com/invite/0012")))
    }

    @Test func nativeGeneratedResourcesResolveEnglish() {
        var resource = LocalizedStringResource.AppStrings.commonSave
        resource.locale = Locale(identifier: "en_US")
        #expect(String(localized: resource) == "Save")
    }
}
