import Domain
import OpenAPI

public extension APIClient {
    static func live(
        client api: APIProtocol,
        provideFcmToken: @escaping @Sendable () async -> String?,
        sessionCache: APIClientCache = APIClientCache()
    ) -> APIClient {
        APIClient(
            answerSuggestionEvaluation: makeAnswerSuggestionEvaluation(api: api),
            listSuggestions: makeListSuggestions(api: api),
            createSuggestion: makeCreateSuggestion(api: api),
            setSuggestionSupport: makeSetSuggestionSupport(api: api),
            reportSuggestion: makeReportSuggestion(api: api),
            withdrawSuggestion: makeWithdrawSuggestion(api: api),
            getTeamContext: { try await withAuthorization { EmployeeTeamContext(try await api.context(.init()).ok.body.json) } },
            requestTeamMembership: { id, code, name in
                try await withAuthorization {
                    EmployeeTeamContext(try await api.join(.init(body: .json(.init(id: id.uuidString, code: code, name: name)))).ok.body.json)
                }
            },
            cancelTeamRequest: { id in
                try await withAuthorization {
                    EmployeeTeamContext(try await api.cancel(.init(path: .init(requestId: id))).ok.body.json)
                }
            },
            leaveTeam: { id in
                try await withAuthorization {
                    EmployeeTeamContext(try await api.leave(.init(path: .init(teamId: id))).ok.body.json)
                }
            },
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
            getBootstrapUpdate: makeGetBootstrapUpdate(api: api, sessionCache: sessionCache),
            markNotificationHistoryAsSeen: makeMarkNotificationHistoryAsSeen(api: api, sessionCache: sessionCache),
            submitProductContact: makeSubmitProductContact(api: api)
        )
    }
}
