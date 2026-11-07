import Localization
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct EmployeeTeamMembership: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared var bootstrap: Bootstrap
        var code = ""
        var name = ""
        var isBusy = false
        var hasLoaded = false
        var requestID: UUID?
        var context: EmployeeTeamContext? { bootstrap.teamContext }
        @Presents var alert: AlertState<AlertAction>?

        public init(bootstrap: Shared<Bootstrap>, code: String = "") {
            self._bootstrap = bootstrap
            self.code = code
        }

        var canSubmit: Bool {
            !isBusy && hasLoaded && context != nil && context?.membership == nil &&
            context?.request?.status != .pending && context?.isLeader == false &&
            !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && code.count <= 64 &&
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count <= 100
        }
    }

    public enum AlertAction: Equatable, Sendable { case confirmLeave, confirmCancel }
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case refresh
        case submit
        case cancelTapped
        case leaveTapped
        case response(EmployeeTeamContext)
        case failed(Error)
        case cancelled
        case alert(PresentationAction<AlertAction>)
    }

    public init() {}
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .refresh:
                guard !state.isBusy else { return .none }
                state.isBusy = true
                return request { try await apiClient.getTeamContext() }
            case .submit:
                guard state.canSubmit else { return .none }
                let id = state.requestID ?? uuid()
                state.requestID = id
                state.isBusy = true
                let code = state.code.trimmingCharacters(in: .whitespacesAndNewlines)
                let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return request { try await apiClient.requestTeamMembership(id, code, name) }
            case .response(let context):
                state.isBusy = false
                state.hasLoaded = true
                state.$bootstrap.withLock { $0.teamContext = context }
                if context.membership != nil || context.request?.status == .pending {
                    state.requestID = nil
                    state.code = ""
                    state.name = ""
                }
                return .none
            case .cancelled:
                state.isBusy = false
                return .none
            case .failed(let error):
                state.isBusy = false
                state.alert = .init(error: error)
                return .none
            case .cancelTapped:
                guard !state.isBusy else { return .none }
                state.alert = .init(
                    title: { TextState(String(appStrings: .teamCancelTitle)) },
                    actions: {
                        ButtonState(role: .destructive, action: .confirmCancel) { TextState(String(appStrings: .teamCancelAction)) }
                        ButtonState(role: .cancel) { TextState(String(appStrings: .commonCancel)) }
                    }
                )
                return .none
            case .leaveTapped:
                guard !state.isBusy else { return .none }
                state.alert = .init(
                    title: { TextState(String(appStrings: .teamLeaveTitle)) },
                    actions: {
                        ButtonState(role: .destructive, action: .confirmLeave) { TextState(String(appStrings: .teamLeaveAction)) }
                        ButtonState(role: .cancel) { TextState(String(appStrings: .commonCancel)) }
                    },
                    message: { TextState(String(appStrings: .teamLeaveMessage)) }
                )
                return .none
            case .alert(.presented(.confirmCancel)):
                guard !state.isBusy, let id = state.context?.request?.id else { return .none }
                state.isBusy = true
                state.requestID = nil
                return request { try await apiClient.cancelTeamRequest(id) }
            case .alert(.presented(.confirmLeave)):
                guard !state.isBusy, let id = state.context?.membership?.id else { return .none }
                state.isBusy = true
                state.requestID = nil
                return request { try await apiClient.leaveTeam(id) }
            case .binding(\.code), .binding(\.name):
                state.requestID = nil
                return .none
            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func request(_ operation: @escaping @Sendable () async throws -> EmployeeTeamContext) -> Effect<Action> {
        .run { send in
            do {
                await send(.response(try await operation()))
            } catch is CancellationError {
                await send(.cancelled)
            } catch {
                await send(.failed(error))
            }
        }
    }
}
