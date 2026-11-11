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
                                               hasFiveSupporters: true, supportedByMe: true, mine: false, decisions: [
                                                .init(id: "decision", revision: 2, status: .deferred, explanation: "Next quarter",
                                                      responsibleName: "Ada", followUpDate: "2099-01-01", publishedAt: 1_794_297_600_000),
                                                .init(id: "previous", revision: 1, status: .reviewing, explanation: "Investigating",
                                                      responsibleName: "Grace", followUpDate: "2098-12-01", publishedAt: 1_794_211_200_000)
                                               ], trials: [], evaluations: [], outcomes: [])
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
        #expect(items[0].hasFiveSupporters); #expect(items[0].supportedByMe); #expect(!items[0].mine)
        #expect(items[0].decisions.map(\.id) == ["decision", "previous"])
        #expect(items[0].decisions[0].status == .deferred)
        #expect(items[0].decisions[0].responsibleName == "Ada")
        #expect(items[0].decisions[0].explanation == "Next quarter")
        #expect(items[0].decisions[0].publishedAt == Date(timeIntervalSince1970: 1_794_297_600))
        #expect(items[0].decisions[0].followUpDate == (try Date("2099-01-01T00:00:00Z", strategy: .iso8601)))
        #expect(try await client.createSuggestion("team", id, "Meetings", "Focus", nil) == items)
        #expect(try await client.setSuggestionSupport("team", id.uuidString, false) == items)
        #expect(try await client.reportSuggestion("team", id.uuidString) == items)
        #expect(try await client.withdrawSuggestion("team", id.uuidString).isEmpty)
    }
}


extension SuggestionAdapterTests {
    @Test
    func malformedDecisionDateFailsMapping() {
        let dto = Components.Schemas.SuggestionDecision(id: "bad", revision: 1, status: .planned,
            explanation: "Plan", responsibleName: "Ada", followUpDate: "not-a-date", publishedAt: 0)
        #expect(throws: (any Error).self) { try SuggestionDecision(dto) }
    }
}

extension SuggestionAdapterTests {
    @Test
    func trialMappingPreservesPlanDatesAndDepartureState() throws {
        let dto = Components.Schemas.SuggestionTrial(
            id: "trial", revision: 2, decisionId: "decision", change: "Meeting-free mornings",
            intendedBenefit: "Focus", responsibleName: "Grace", needsReassignment: true,
            startDate: "2099-01-01", endDate: "2099-02-01", followUpDate: "2099-02-02", publishedAt: 1_794_297_600_000
        )
        let mapped = try SuggestionTrial(dto)
        #expect(mapped.id == "trial")
        #expect(mapped.revision == 2)
        #expect(mapped.decisionId == "decision")
        #expect(mapped.change == "Meeting-free mornings")
        #expect(mapped.intendedBenefit == "Focus")
        #expect(mapped.responsibleName == "Grace")
        #expect(mapped.needsReassignment)
        #expect(mapped.startDate == (try Date("2099-01-01T00:00:00Z", strategy: .iso8601)))
        #expect(mapped.endDate == (try Date("2099-02-01T00:00:00Z", strategy: .iso8601)))
        #expect(mapped.followUpDate == (try Date("2099-02-02T00:00:00Z", strategy: .iso8601)))
        #expect(mapped.publishedAt == Date(timeIntervalSince1970: 1_794_297_600))
    }

    @Test
    func malformedTrialDateFailsMapping() {
        let dto = Components.Schemas.SuggestionTrial(
            id: "trial", revision: 1, decisionId: "decision", change: "Mornings", intendedBenefit: "Focus",
            responsibleName: "Ada", needsReassignment: false, startDate: "bad", endDate: "2099-02-01",
            followUpDate: "2099-02-02", publishedAt: 0
        )
        #expect(throws: (any Error).self) { try SuggestionTrial(dto) }
    }
}


extension SuggestionAdapterTests {
    @Test
    func evaluationAnswerUsesGeneratedOperationAndMapsPrivateResponse() async throws {
        let dto = Components.Schemas.Suggestion(id: "idea", problem: "Meetings", impact: "Focus", hasFiveSupporters: false,
            supportedByMe: false, mine: false, decisions: [], trials: [], evaluations: [
                .init(id: "evaluation", trialId: "trial", closesAt: 1000, closed: false, eligible: true, myAnswer: .better)
            ], outcomes: [])
        var api = MockAPI()
        api.answerSuggestionEvaluationHandler = { input in
            #expect(input.path.teamId == "team")
            #expect(input.path.suggestionId == "idea")
            #expect(input.path.evaluationId == "evaluation")
            guard case .json(let body) = input.body else { Issue.record("Expected JSON"); return .ok(.init(body: .json([]))) }
            #expect(body.answer == .better)
            return .ok(.init(body: .json([dto])))
        }
        let client = APIClient.live(client: api, provideFcmToken: { nil })
        let response = try await client.answerSuggestionEvaluation("team", "idea", "evaluation", .better)
        #expect(response[0].evaluations[0].myAnswer == .better)
        #expect(response[0].evaluations[0].summary == nil)
        #expect(response[0].evaluations[0].closesAt == Date(timeIntervalSince1970: 1))
    }
}
