import Domain
import OpenAPI

public extension APIClient {
    static func live(
        client api: APIProtocol,
        provideFcmToken: @escaping @Sendable () async -> String?,
        sessionCache: APIClientCache = APIClientCache()
    ) -> APIClient {
        APIClient(
            deleteAccount: makeDeleteAccount(api: api),
            modifyAccount: makeModifyAccount(api: api, sessionCache: sessionCache),
            linkFCMTokenToAccount: makeLinkFCMTokenToAccount(api: api),
            logout: makeLogout(api: api, provideFcmToken: provideFcmToken),
            getBootstrap: makeGetBootstrap(api: api, sessionCache: sessionCache),
            startFeedbackSession: makeStartFeedbackSession(api: api),
            submitFeedback: makeSubmitFeedback(api: api, sessionCache: sessionCache),
            createActivity: makeCreateActivity(api: api, sessionCache: sessionCache),
            updateActivity: makeUpdateActivity(api: api, sessionCache: sessionCache),
            deleteActivity: makeDeleteActivity(api: api, sessionCache: sessionCache),
            createSession: makeCreateSession(api: api, sessionCache: sessionCache),
            updateSession: makeUpdateSession(api: api, sessionCache: sessionCache),
            deleteSession: makeDeleteSession(api: api, sessionCache: sessionCache),
            createAccount: makeCreateAccount(api: api, provideFcmToken: provideFcmToken, sessionCache: sessionCache),
            sessionChangedListener: makeSessionChangedListener(sessionCache: sessionCache),
            joinSession: makeJoinSession(api: api, sessionCache: sessionCache),
            markSessionAsSeen: makeMarkSessionAsSeen(api: api, sessionCache: sessionCache),
            sendNotification: makeSendNotification(api: api),
            updateRole: makeUpdateRole(api: api),
            mockIdToken: makeMockIdToken(api: api),
            getBoostrapUpdate: makeGetBoostrapUpdate(api: api, sessionCache: sessionCache),
            markNotificationHistoryAsSeen: makeMarkNotificationHistoryAsSeen(api: api, sessionCache: sessionCache)
        )
    }
}
