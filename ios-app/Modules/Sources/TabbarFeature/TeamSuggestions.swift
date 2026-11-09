import ComposableArchitecture
import Domain
import Foundation
import Localization

@Reducer
public struct TeamSuggestions: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared var bootstrap: Bootstrap
        var suggestions: [Suggestion] = []
        var problem = ""
        var impact = ""
        var solution = ""
        var submissionID: UUID?
        var isBusy = false
        var hasLoaded = false
        var submitted = false
        var reportSubmitted = false
        var teamID: String? { bootstrap.teamContext?.membership?.id }
        @Presents var alert: AlertState<AlertAction>?

        public init(bootstrap: Shared<Bootstrap>) { self._bootstrap = bootstrap }

        var canSubmit: Bool {
            !isBusy && hasLoaded && teamID != nil && Self.valid(problem) && Self.valid(impact) && solution.utf16.count <= 1000
        }

        private static func valid(_ value: String) -> Bool {
            !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && value.utf16.count <= 1000
        }
    }

    public enum AlertAction: Equatable, Sendable { case withdraw(String), report(String) }
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case refresh
        case submit
        case support(String)
        case reportTapped(String)
        case withdrawTapped(String)
        case response(String, [Suggestion], submitted: Bool, reported: Bool = false)
        case failed(String, Error)
        case cancelled(String)
        case membershipChanged
        case alert(PresentationAction<AlertAction>)
    }

    private enum CancelID { case request }
    public init() {}
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .refresh:
                guard !state.isBusy, let teamID = state.teamID else { return .none }
                state.isBusy = true
                return request(teamID: teamID) { try await apiClient.listSuggestions(teamID) }
            case .submit:
                guard state.canSubmit, let teamID = state.teamID else { return .none }
                let id = state.submissionID ?? uuid()
                state.submissionID = id
                state.isBusy = true
                state.submitted = false
                let problem = state.problem.trimmingCharacters(in: .whitespacesAndNewlines)
                let impact = state.impact.trimmingCharacters(in: .whitespacesAndNewlines)
                let solution = state.solution.trimmingCharacters(in: .whitespacesAndNewlines)
                return request(teamID: teamID, submitted: true) {
                    try await apiClient.createSuggestion(teamID, id, problem, impact, solution.isEmpty ? nil : solution)
                }
            case .support(let id):
                guard !state.isBusy, state.hasLoaded, let teamID = state.teamID,
                      let suggestion = state.suggestions.first(where: { $0.id == id }) else { return .none }
                state.isBusy = true
                return request(teamID: teamID) { try await apiClient.setSuggestionSupport(teamID, id, !suggestion.supportedByMe) }
            case .reportTapped(let id):
                guard !state.isBusy, state.hasLoaded, state.suggestions.contains(where: { $0.id == id }) else { return .none }
                state.alert = .init(
                    title: { TextState(String(appStrings: .suggestionsReportTitle)) },
                    actions: {
                        ButtonState(action: .report(id)) { TextState(String(appStrings: .suggestionsReport)) }
                        ButtonState(role: .cancel) { TextState(String(appStrings: .commonCancel)) }
                    },
                    message: { TextState(String(appStrings: .suggestionsReportExplanation)) }
                )
                return .none
            case .alert(.presented(.report(let id))):
                guard !state.isBusy, state.hasLoaded, let teamID = state.teamID,
                      state.suggestions.contains(where: { $0.id == id }) else { return .none }
                state.isBusy = true
                state.reportSubmitted = false
                return request(teamID: teamID, reported: true) { try await apiClient.reportSuggestion(teamID, id) }
            case .withdrawTapped(let id):
                guard !state.isBusy, state.suggestions.contains(where: { $0.id == id && $0.mine }) else { return .none }
                state.alert = .init(
                    title: { TextState(String(appStrings: .suggestionsWithdrawTitle)) },
                    actions: {
                        ButtonState(role: .destructive, action: .withdraw(id)) { TextState(String(appStrings: .suggestionsWithdraw)) }
                        ButtonState(role: .cancel) { TextState(String(appStrings: .commonCancel)) }
                    }
                )
                return .none
            case .alert(.presented(.withdraw(let id))):
                guard !state.isBusy, let teamID = state.teamID,
                      state.suggestions.contains(where: { $0.id == id && $0.mine }) else { return .none }
                state.isBusy = true
                return request(teamID: teamID) { try await apiClient.withdrawSuggestion(teamID, id) }
            case let .response(teamID, suggestions, submitted, reported):
                guard teamID == state.teamID else { return .none }
                state.isBusy = false
                state.hasLoaded = true
                state.suggestions = suggestions
                if reported { state.reportSubmitted = true }
                if submitted {
                    state.problem = ""
                    state.impact = ""
                    state.solution = ""
                    state.submissionID = nil
                    state.submitted = true
                }
                return .none
            case .failed(let teamID, let error):
                guard teamID == state.teamID else { return .none }
                state.isBusy = false
                state.hasLoaded = false
                state.suggestions = []
                state.alert = .init(error: error)
                return .none
            case .cancelled(let teamID):
                guard teamID == state.teamID else { return .none }
                state.isBusy = false
                return .none
            case .membershipChanged:
                state.suggestions = []
                state.problem = ""
                state.impact = ""
                state.solution = ""
                state.submissionID = nil
                state.isBusy = false
                state.hasLoaded = false
                state.submitted = false
                state.reportSubmitted = false
                state.alert = nil
                return .cancel(id: CancelID.request)
            case .binding(\.problem), .binding(\.impact), .binding(\.solution):
                state.submissionID = nil
                state.submitted = false
                return .none
            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func request(
        teamID: String,
        submitted: Bool = false,
        reported: Bool = false,
        operation: @escaping @Sendable () async throws -> [Suggestion]
    ) -> Effect<Action> {
        .run { send in
            do {
                await send(.response(teamID, try await operation(), submitted: submitted, reported: reported))
            } catch is CancellationError {
                await send(.cancelled(teamID))
            } catch {
                await send(.failed(teamID, error))
            }
        }
        .cancellable(id: CancelID.request)
    }
}
