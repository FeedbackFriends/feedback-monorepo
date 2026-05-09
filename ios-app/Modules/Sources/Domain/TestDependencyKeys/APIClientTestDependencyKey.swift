import ComposableArchitecture

extension APIClient: TestDependencyKey {
    public static let previewValue = APIClient()
    public static let testValue = APIClient(
        deleteAccount: {},
        modifyAccount: { _, _, _ in},
        linkFCMTokenToAccount: { _ in },
        logout: {},
        getBootstrap: { .mock() },
        startFeedbackSession: { _ in .mock },
        submitFeedback: { _, _ in true },
        createActivity: { _ in .mock() },
        updateActivity: { _, _ in .mock() },
        deleteActivity: { _ in },
        createSession: { _ in .mock() },
        updateSession: { _, _ in .mock() },
        deleteSession: { _ in },
        createAccount: { _ in .mock() },
        sessionChangedListener: { .never },
        joinSession: { _ in .mock() },
        markSessionAsSeen: { _ in },
        sendNotification: { _ in },
        updateRole: { _ in },
        mockIdToken: { "" },
        getBoostrapUpdate: { .mock() },
        markNotificationHistoryAsSeen: { }
    )
}
