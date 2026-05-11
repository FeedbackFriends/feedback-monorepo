import Domain
import OpenAPI
import Utility

extension APIClient {
    static func makeDeleteAccount(api: APIProtocol) -> @Sendable () async throws -> Void {
        {
            try await withAuthorization {
                _ = try await api.deleteAccount(.init())
                return ()
            }
        }
    }

    static func makeModifyAccount(api: APIProtocol, sessionCache: APIClientCache) -> @Sendable (String, String, String) async throws -> Void {
        { name, email, phoneNumber in
            try await withAuthorization {
                _ = try await api.modifyAccount(
                    .init(
                        body: .json(
                            .init(
                                name: name.nilIfEmpty,
                                email: email.nilIfEmpty,
                                phoneNumber: phoneNumber.nilIfEmpty
                            )
                        )
                    )
                ).ok
                await sessionCache.updateAccount(
                    name: name.nilIfEmpty,
                    email: email.nilIfEmpty,
                    phoneNumber: phoneNumber.nilIfEmpty
                )
                return ()
            }
        }
    }

    static func makeLinkFCMTokenToAccount(api: APIProtocol) -> @Sendable (String) async throws -> Void {
        { fcmToken in
            try await withAuthorization {
                _ = try await api.linkFCMTokenToAccount(body: .json(.init(fcmToken: fcmToken)))
                return ()
            }
        }
    }

    static func makeLogout(api: APIProtocol, provideFcmToken: @escaping @Sendable () async -> String?) -> @Sendable () async throws -> Void {
        {
            guard let fcmToken = await provideFcmToken() else { return }
            try await withAuthorization {
                _ = try await api.logout(body: .json(.init(fcmToken: fcmToken)))
                return ()
            }
        }
    }

    static func makeCreateAccount(
        api: APIProtocol,
        provideFcmToken: @escaping @Sendable () async -> String?,
        sessionCache: APIClientCache
    ) -> @Sendable (Role?) async throws -> Bootstrap {
        { optionalRole in
            try await withAuthorization(forceRefreshAfter: true) {
                let fcmToken = await provideFcmToken()
                let bootstrap = try await api.createAccount(
                    .init(
                        body: .json(
                            .init(
                                requestedRole: optionalRole?.rawValue.uppercasingFirst(),
                                fcmToken: fcmToken
                            )
                        )
                    )
                ).ok.body.json
                let session = Bootstrap(bootstrap)
                await sessionCache.updateSession(session)
                return session
            }
        }
    }

    static func makeUpdateRole(api: APIProtocol) -> @Sendable (Role) async throws -> Void {
        { role in
            try await withAuthorization(forceRefreshAfter: true) {
                _ = try await api.updateRole(.init(body: .json(.init(role: role.rawValue.uppercasingFirst()))))
                return ()
            }
        }
    }

    static func makeSeedParticipantWithData(api: APIProtocol) -> @Sendable () async throws -> MockTokenDto {
        {
            MockTokenDto(try await api.seedParticipantWithData().ok.body.json)
        }
    }

    static func makeSeedParticipantEmpty(api: APIProtocol) -> @Sendable () async throws -> MockTokenDto {
        {
            MockTokenDto(try await api.seedParticipantEmpty().ok.body.json)
        }
    }

    static func makeSeedManagerWithData(api: APIProtocol) -> @Sendable () async throws -> MockTokenDto {
        {
            MockTokenDto(try await api.seedManagerWithData().ok.body.json)
        }
    }

    static func makeSeedManagerEmpty(api: APIProtocol) -> @Sendable () async throws -> MockTokenDto {
        {
            MockTokenDto(try await api.seedManagerEmpty().ok.body.json)
        }
    }

    static func makeSeedEmptyAccount(api: APIProtocol) -> @Sendable () async throws -> MockTokenDto {
        {
            MockTokenDto(try await api.seedEmptyAccount().ok.body.json)
        }
    }

    static func makeLogin(api: APIProtocol) -> @Sendable (String) async throws -> MockTokenDto {
        { id in
            MockTokenDto(try await api.login(body: .json(.init(id: id))).ok.body.json)
        }
    }
}
