import Domain
import Foundation
import OpenAPI

extension APIClient {
    static func makeListSuggestions(api: APIProtocol) -> @Sendable (String) async throws -> [Suggestion] {
        { teamID in
            try await withAuthorization {
                try await api.listSuggestions(.init(path: .init(teamId: teamID))).ok.body.json.map(Suggestion.init)
            }
        }
    }

    static func makeCreateSuggestion(api: APIProtocol) -> @Sendable (String, UUID, String, String, String?) async throws -> [Suggestion] {
        { teamID, id, problem, impact, solution in
            try await withAuthorization {
                try await api.createSuggestion(.init(
                    path: .init(teamId: teamID),
                    body: .json(.init(id: id.uuidString, problem: problem, impact: impact, solution: solution))
                )).ok.body.json.map(Suggestion.init)
            }
        }
    }

    static func makeSetSuggestionSupport(api: APIProtocol) -> @Sendable (String, String, Bool) async throws -> [Suggestion] {
        { teamID, suggestionID, supported in
            try await withAuthorization {
                try await api.setSuggestionSupport(.init(
                    path: .init(teamId: teamID, suggestionId: suggestionID), body: .json(.init(supported: supported))
                )).ok.body.json.map(Suggestion.init)
            }
        }
    }

    static func makeReportSuggestion(api: APIProtocol) -> @Sendable (String, String) async throws -> [Suggestion] {
        { teamID, suggestionID in
            try await withAuthorization {
                try await api.reportSuggestion(.init(path: .init(teamId: teamID, suggestionId: suggestionID))).ok.body.json.map(Suggestion.init)
            }
        }
    }

    static func makeWithdrawSuggestion(api: APIProtocol) -> @Sendable (String, String) async throws -> [Suggestion] {
        { teamID, suggestionID in
            try await withAuthorization {
                try await api.withdrawSuggestion(.init(path: .init(teamId: teamID, suggestionId: suggestionID))).ok.body.json.map(Suggestion.init)
            }
        }
    }
}
