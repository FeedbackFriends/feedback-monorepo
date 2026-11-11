import ComposableArchitecture

extension APIClient: TestDependencyKey {
    public static let previewValue = APIClient()
    public static let testValue = APIClient(
        answerSuggestionEvaluation: { _, _, _, _ in [] },
        listSuggestions: { _ in [] },
        createSuggestion: { _, _, _, _, _ in [] },
        setSuggestionSupport: { _, _, _ in [] },
        reportSuggestion: { _, _ in [] },
        withdrawSuggestion: { _, _ in [] },
        getTeamContext: { .init() },
        requestTeamMembership: { _, _, _ in .init() },
        cancelTeamRequest: { _ in .init() },
        leaveTeam: { _ in .init() },
        deleteAccount: {},
        modifyAccount: { _, _, _ in},
        linkFCMTokenToAccount: { _ in },
        logout: {},
        getBootstrap: { .mock() },
        startFeedbackEvent: { _ in .mock },
        submitFeedback: { _, _ in true },
        createActivity: { _ in .mock() },
        updateActivity: { _, _ in .mock() },
        deleteActivity: { _ in },
        createEvent: { _ in .mock() },
        updateEvent: { _, _ in .mock() },
        deleteEvent: { _ in },
        createAccount: { _ in .mock() },
        sessionChangedListener: { .never },
        joinEvent: { _ in .mock() },
        markEventAsSeen: { _ in },
        sendNotification: { _ in },
        getBootstrapUpdate: { .mock() },
        markNotificationHistoryAsSeen: { },
        submitProductContact: { _ in throw AppFailure.supportReceiptUnavailable }
    )
}
