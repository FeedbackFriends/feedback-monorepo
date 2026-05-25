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
            startFeedbackEvent: makeStartFeedbackEvent(api: api),
            submitFeedback: makeSubmitFeedback(api: api, sessionCache: sessionCache),
            createActivity: makeCreateActivity(api: api, sessionCache: sessionCache),
            updateActivity: makeUpdateActivity(api: api, sessionCache: sessionCache),
            deleteActivity: makeDeleteActivity(api: api, sessionCache: sessionCache),
            createEvent: makeCreateEvent(api: api, sessionCache: sessionCache),
            updateEvent: makeUpdateEvent(api: api, sessionCache: sessionCache),
            deleteEvent: makeDeleteEvent(api: api, sessionCache: sessionCache),
            createAccount: makeCreateAccount(api: api, provideFcmToken: provideFcmToken, sessionCache: sessionCache),
            sessionChangedListener: makeSessionChangedListener(sessionCache: sessionCache),
            joinEvent: makeJoinEvent(api: api, sessionCache: sessionCache),
            markEventAsSeen: makeMarkEventAsSeen(api: api, sessionCache: sessionCache),
            sendNotification: makeSendNotification(api: api),
            updateRole: makeUpdateRole(api: api),
            seedParticipantWithData: makeSeedParticipantWithData(api: api),
            seedParticipantEmpty: makeSeedParticipantEmpty(api: api),
            seedManagerWithData: makeSeedManagerWithData(api: api),
            seedManagerEmpty: makeSeedManagerEmpty(api: api),
            seedEmptyAccount: makeSeedEmptyAccount(api: api),
            resetDatabase: makeResetDatabase(api: api, sessionCache: sessionCache),
            login: makeLogin(api: api),
            getBootstrapUpdate: makeGetBootstrapUpdate(api: api, sessionCache: sessionCache),
            markNotificationHistoryAsSeen: makeMarkNotificationHistoryAsSeen(api: api, sessionCache: sessionCache)
        )
    }
}
