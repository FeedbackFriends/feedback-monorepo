@testable import TabbarFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct TeamSuggestionsTests {
    let team = EmployeeTeam(id: "team", name: "IT", organizationName: "Acme")
    let idea = Suggestion(id: "idea", problem: "Meetings", impact: "Focus", solution: nil, hasFiveSupporters: false, supportedByMe: false, mine: true)

    private func state() -> TeamSuggestions.State {
        let shared = Shared(value: Bootstrap.mockAnonymous())
        shared.withLock { $0.teamContext = .init(membership: team) }
        return .init(bootstrap: shared)
    }

    @Test
    func submissionRequiresLoadedMembershipAndValidFields() async {
        var initial = state()
        initial.problem = "Meetings"
        initial.impact = "Focus"
        let store = TestStore(initialState: initial) { TeamSuggestions() }
        await store.send(.submit)
        #expect(!store.state.canSubmit)
        initial.hasLoaded = true
        #expect(initial.canSubmit)
        initial.problem = " \n "
        #expect(!initial.canSubmit)
        initial.problem = String(repeating: "😀", count: 501)
        #expect(!initial.canSubmit)
        initial.problem = "Meetings"
        initial.solution = String(repeating: "a", count: 1001)
        #expect(!initial.canSubmit)
        initial.solution = ""
        initial.$bootstrap.withLock { $0.teamContext = .init() }
        #expect(!initial.canSubmit)
    }

    @Test
    func busyStateRejectsDuplicateMutations() async {
        var initial = state()
        initial.hasLoaded = true
        initial.isBusy = true
        initial.problem = "Meetings"
        initial.impact = "Focus"
        initial.suggestions = [idea]
        let store = TestStore(initialState: initial) { TeamSuggestions() }
        await store.send(.submit)
        await store.send(.support("idea"))
        await store.send(.withdrawTapped("idea"))
        await store.send(.refresh)
    }

    @Test
    func retryKeepsSubmissionIdentityAndDraftUntilSuccess() async {
        let id = UUID()
        var initial = state()
        initial.hasLoaded = true
        initial.problem = " Meetings "
        initial.impact = " Focus "
        let error = URLError(.timedOut)
        let store = TestStore(initialState: initial) { TeamSuggestions() } withDependencies: {
            $0.uuid = .constant(id)
            $0.apiClient.createSuggestion = { _, _, _, _, _ in throw error }
        }
        await store.send(.submit) { $0.isBusy = true; $0.submissionID = id }
        await store.receive(\.failed) {
            $0.isBusy = false; $0.hasLoaded = false; $0.alert = .init(error: error)
        }
        #expect(store.state.problem == " Meetings ")
        #expect(store.state.submissionID == id)
        await store.send(.alert(.dismiss)) { $0.alert = nil }
        store.dependencies.apiClient.listSuggestions = { _ in [] }
        await store.send(.refresh) { $0.isBusy = true }
        await store.receive(\.response) { $0.isBusy = false; $0.hasLoaded = true }
        store.dependencies.apiClient.createSuggestion = { teamID, receivedID, problem, impact, solution in
            #expect(teamID == "team"); #expect(receivedID == id)
            #expect(problem == "Meetings"); #expect(impact == "Focus"); #expect(solution == nil)
            return [idea]
        }
        await store.send(.submit) { $0.isBusy = true }
        await store.receive(\.response) {
            $0.isBusy = false; $0.suggestions = [idea]; $0.submissionID = nil
            $0.problem = ""; $0.impact = ""; $0.submitted = true
        }
    }

    @Test
    func supportUsesServerResultAndMembershipChangeDiscardsProtectedContent() async {
        var initial = state()
        initial.hasLoaded = true
        initial.suggestions = [idea]
        let supported = Suggestion(id: idea.id, problem: idea.problem, impact: idea.impact, solution: nil,
                                   hasFiveSupporters: false, supportedByMe: true, mine: true)
        let store = TestStore(initialState: initial) { TeamSuggestions() } withDependencies: {
            $0.apiClient.setSuggestionSupport = { teamID, suggestionID, supportedByMe in
                #expect(teamID == "team"); #expect(suggestionID == "idea"); #expect(supportedByMe)
                return [supported]
            }
        }
        await store.send(.support("foreign"))
        await store.send(.support("idea")) { $0.isBusy = true }
        await store.receive(\.response) { $0.isBusy = false; $0.suggestions = [supported] }
        await store.send(.membershipChanged) { $0.suggestions = []; $0.hasLoaded = false }
        store.state.$bootstrap.withLock { $0.teamContext = .init() }
        await store.send(.response("team", [idea], submitted: false))
        #expect(store.state.suggestions.isEmpty)
    }

    @Test
    func cancellationReleasesBusyStateAndFailureClearsFeed() async {
        var initial = state()
        initial.hasLoaded = true
        initial.suggestions = [idea]
        let store = TestStore(initialState: initial) { TeamSuggestions() } withDependencies: {
            $0.apiClient.listSuggestions = { _ in throw CancellationError() }
        }
        await store.send(.refresh) { $0.isBusy = true }
        await store.receive(\.cancelled) { $0.isBusy = false }
        let error = URLError(.userAuthenticationRequired)
        store.dependencies.apiClient.listSuggestions = { _ in throw error }
        await store.send(.refresh) { $0.isBusy = true }
        await store.receive(\.failed) {
            $0.isBusy = false; $0.hasLoaded = false; $0.suggestions = []; $0.alert = .init(error: error)
        }
    }
    @Test
    func reportingRequiresConfirmationAndOnlyConfirmsAfterServerSuccess() async {
        var initial = state()
        initial.hasLoaded = true
        initial.suggestions = [idea]
        let store = TestStore(initialState: initial) { TeamSuggestions() } withDependencies: {
            $0.apiClient.reportSuggestion = { teamID, suggestionID in
                #expect(teamID == "team"); #expect(suggestionID == "idea")
                return [idea]
            }
        }
        await store.send(.reportTapped("foreign"))
        await store.withExhaustivity(.off) { _ = await store.send(.reportTapped("idea")) }
        #expect(store.state.alert != nil)
        #expect(!store.state.reportSubmitted)
        await store.send(.alert(.presented(.report("idea")))) { $0.alert = nil; $0.isBusy = true }
        await store.receive(\.response) { $0.isBusy = false; $0.reportSubmitted = true }
        await store.send(.membershipChanged) {
            $0.suggestions = []; $0.hasLoaded = false; $0.reportSubmitted = false
        }
    }

}
