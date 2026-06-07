import ComposableArchitecture

extension APIClient: TestDependencyKey {
    public static let previewValue = APIClient()
    public static let testValue = APIClient(
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
        updateRole: { _ in },
        getBootstrapUpdate: { .mock() },
        markNotificationHistoryAsSeen: { }
    )
}
