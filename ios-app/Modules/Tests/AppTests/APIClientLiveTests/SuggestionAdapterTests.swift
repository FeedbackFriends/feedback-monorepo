@testable import Adapters
import Domain
import Foundation
import OpenAPI
import Testing

@MainActor
struct SuggestionAdapterTests {
    @Test
    func suggestionsMapCallerFlagsAndForwardTeamAndRetryIdentity() async throws {
        let id = UUID()
        let dto = Components.Schemas.Suggestion(id: id.uuidString, problem: "Meetings", impact: "Focus", solution: nil,
                                               supportCount: 2, supportedByMe: true, mine: false)
        var api = MockAPI()
        api.listSuggestionsHandler = { input in
            #expect(input.path.teamId == "team")
            return .ok(.init(body: .json([dto])))
        }
        api.createSuggestionHandler = { input in
            #expect(input.path.teamId == "team")
            guard case .json(let body) = input.body else { Issue.record("Expected JSON"); return .ok(.init(body: .json([]))) }
            #expect(body.id == id.uuidString)
            #expect(body.problem == "Meetings"); #expect(body.impact == "Focus"); #expect(body.solution == nil)
            return .ok(.init(body: .json([dto])))
        }
        api.setSuggestionSupportHandler = { input in
            #expect(input.path.teamId == "team"); #expect(input.path.suggestionId == id.uuidString)
            guard case .json(let body) = input.body else { Issue.record("Expected JSON"); return .ok(.init(body: .json([]))) }
            #expect(body.supported == false)
            return .ok(.init(body: .json([dto])))
        }
        api.reportSuggestionHandler = { input in
            #expect(input.path.teamId == "team"); #expect(input.path.suggestionId == id.uuidString)
            return .ok(.init(body: .json([dto])))
        }
        api.withdrawSuggestionHandler = { input in
            #expect(input.path.teamId == "team"); #expect(input.path.suggestionId == id.uuidString)
            return .ok(.init(body: .json([])))
        }
        let client = APIClient.live(client: api, provideFcmToken: { nil })
        let items = try await client.listSuggestions("team")
        #expect(items.count == 1)
        #expect(items[0].supportCount == 2); #expect(items[0].supportedByMe); #expect(!items[0].mine)
        #expect(try await client.createSuggestion("team", id, "Meetings", "Focus", nil) == items)
        #expect(try await client.setSuggestionSupport("team", id.uuidString, false) == items)
        #expect(try await client.reportSuggestion("team", id.uuidString) == items)
        #expect(try await client.withdrawSuggestion("team", id.uuidString).isEmpty)
    }
}
