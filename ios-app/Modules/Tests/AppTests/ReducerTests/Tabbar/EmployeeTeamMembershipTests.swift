@testable import TabbarFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct EmployeeTeamMembershipTests {
    let team = EmployeeTeam(id: "team", name: "IT", organizationName: "Acme")

    @Test
    func requestWaitApprovalAndRemovalFollowServerContext() async {
        let requestID = UUID()
        let shared = Shared(value: Bootstrap.mockAnonymous())
        shared.withLock { $0.teamContext = .init() }
        var state = EmployeeTeamMembership.State(bootstrap: shared, code: "invite")
        state.name = " Ada "
        state.hasLoaded = true
        let pending = EmployeeTeamContext(request: .init(id: requestID.uuidString, team: team, status: .pending))
        let store = TestStore(initialState: state) { EmployeeTeamMembership() } withDependencies: {
            $0.uuid = .constant(requestID)
            $0.apiClient.requestTeamMembership = { id, code, name in
                #expect(id == requestID)
                #expect(code == "invite")
                #expect(name == "Ada")
                return pending
            }
            $0.apiClient.getTeamContext = { EmployeeTeamContext(membership: team) }
        }
        await store.send(.submit) { $0.isBusy = true; $0.requestID = requestID }
        await store.receive(\.response) {
            $0.isBusy = false
            $0.requestID = nil
            $0.code = ""
            $0.name = ""
            $0.$bootstrap.withLock { $0.teamContext = pending }
        }
        await store.send(.refresh) { $0.isBusy = true }
        await store.receive(\.response) {
            $0.isBusy = false
            $0.$bootstrap.withLock { $0.teamContext = EmployeeTeamContext(membership: team) }
        }
        store.dependencies.apiClient.getTeamContext = { .init() }
        await store.send(.refresh) { $0.isBusy = true }
        await store.receive(\.response) {
            $0.isBusy = false
            $0.$bootstrap.withLock { $0.teamContext = .init() }
        }
    }

    @Test
    func invalidCodeKeepsInputAndRetryIdentityThenShowsRejection() async {
        let requestID = UUID()
        let shared = Shared(value: Bootstrap.mockAnonymous())
        shared.withLock { $0.teamContext = .init() }
        var state = EmployeeTeamMembership.State(bootstrap: shared, code: "invalid")
        state.name = "Ada"
        state.hasLoaded = true
        let error = URLError(.badServerResponse)
        let store = TestStore(initialState: state) { EmployeeTeamMembership() } withDependencies: {
            $0.uuid = .constant(requestID)
            $0.apiClient.requestTeamMembership = { _, _, _ in throw error }
        }
        await store.send(.submit) { $0.isBusy = true; $0.requestID = requestID }
        await store.receive(\.failed) { $0.isBusy = false; $0.alert = .init(error: error) }
        #expect(store.state.code == "invalid")
        #expect(store.state.requestID == requestID)
        await store.send(.alert(.dismiss)) { $0.alert = nil }
        let rejected = EmployeeTeamContext(request: .init(id: "rejected", team: team, status: .rejected))
        store.dependencies.apiClient.getTeamContext = { rejected }
        await store.send(.refresh) { $0.isBusy = true }
        await store.receive(\.response) {
            $0.isBusy = false
            $0.$bootstrap.withLock { $0.teamContext = rejected }
        }
        #expect(store.state.canSubmit)
    }

    @Test
    func cancelAndLeaveUpdateSharedMembershipAndRequireFreshApproval() async {
        let shared = Shared(value: Bootstrap.mockAnonymous())
        shared.withLock { $0.teamContext = .init(request: .init(id: "request", team: team, status: .pending)) }
        let store = TestStore(initialState: EmployeeTeamMembership.State(bootstrap: shared)) {
            EmployeeTeamMembership()
        } withDependencies: {
            $0.apiClient.cancelTeamRequest = { id in #expect(id == "request"); return .init() }
            $0.apiClient.leaveTeam = { id in #expect(id == "team"); return .init() }
        }
        await store.withExhaustivity(.off) { _ = await store.send(.cancelTapped) }
        #expect(store.state.alert != nil)
        await store.send(.alert(.presented(.confirmCancel))) { $0.isBusy = true; $0.alert = nil }
        await store.receive(\.response) {
            $0.isBusy = false; $0.hasLoaded = true
            $0.$bootstrap.withLock { $0.teamContext = .init() }
        }
        shared.withLock { $0.teamContext = .init(membership: team) }
        await store.withExhaustivity(.off) { _ = await store.send(.leaveTapped) }
        #expect(store.state.alert != nil)
        await store.send(.alert(.presented(.confirmLeave))) { $0.isBusy = true; $0.alert = nil }
        await store.receive(\.response) {
            $0.isBusy = false
            $0.$bootstrap.withLock { $0.teamContext = .init() }
        }
        #expect(!store.state.canSubmit)
    }

    @Test
    func submissionNeedsLoadedContextNameAndValidCode() async {
        let shared = Shared(value: Bootstrap.mockAnonymous())
        var state = EmployeeTeamMembership.State(bootstrap: shared, code: "invite")
        state.name = "Ada"
        let store = TestStore(initialState: state) { EmployeeTeamMembership() }
        await store.send(.submit)
        #expect(!store.state.canSubmit)
    }

    @Test
    func teamLinksStayDistinctFromEventInvitations() {
        #expect(Deeplink(url: URL(string: "letsgrow://team-invite?code=abc-123")!) == .joinTeam(code: "abc-123"))
        #expect(Deeplink(url: URL(string: "letsgrow://team-invite?code=")!) == nil)
        #expect(Deeplink(url: URL(string: "https://team-invite?code=abc")!) == nil)
    }
}
