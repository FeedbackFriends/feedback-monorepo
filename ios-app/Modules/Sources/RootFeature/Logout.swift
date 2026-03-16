import ComposableArchitecture
import Domain

@Reducer
public struct Logout: Sendable {
    
    public init() {}
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        public var logoutInFlight: Bool
        public init(logoutInFlight: Bool = false) {
            self.logoutInFlight = logoutInFlight
        }
    }
    
    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case logoutButtonTap
        case presentError(Error)
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    
    public var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case .destination:
                return .none
                
            case .logoutButtonTap:
                state.logoutInFlight = true
                state.destination = nil
                return .run { send in
                    do {
                        try await apiClient.logout()
                        try await authClient.logout()
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .presentError(let error):
                state.logoutInFlight = false
                state.destination = .alert(.init(error: error))
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Logout.Destination.State: Equatable {}
