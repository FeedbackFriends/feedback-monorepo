import TabbarFeature
import ComposableArchitecture
import SwiftUI
import DesignSystem
import SignUpFeature

public struct RootFeatureView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @Bindable var store: StoreOf<RootFeature>
    
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            switch store.destination {
                
            case .isLoading:
                StartupLoadingView()
                    .transition(.opacity)
                
            case .signUp:
                signUpView
                
            case let .error(errorType):
                errorView(errorType)
                
            case .loggedIn:
                loggedInView
            }
        }
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.themeBackground.ignoresSafeArea())
		.tint(Color.themePrimaryAction)
        .animation(.easeInOut(duration: reduceMotion ? 0 : 0.55), value: store.destination)
        .alert($store.scope(state: \.logout.destination?.alert, action: \.logout.destination.alert))
    }
    
    @ViewBuilder
    private var signUpView: some View {
        IfLetStore(store.scope(state: \.destination.signUp, action: \.destination.signUp)) { store in
            SignUpView(store: store)
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var loggedInView: some View {
        IfLetStore(store.scope(state: \.destination.loggedIn, action: \.destination.loggedIn)) { store in
            TabbarView(store: store)
                .transition(.opacity)
        }
    }
    
    private func errorView(_ errorType: RootFeature.ErrorType) -> some View {
        VStack {
            ErrorView(error: errorType.error, isLoading: $store.isLoading) {
                store.send(.tryAgainButtonTap(errorType))
            }
            Button("Log out") {
                store.send(.logout(.logoutButtonTap))
            }
            .buttonStyle(SecondaryTextButtonStyle())
            .isLoading(store.logout.logoutInFlight)
            .padding(.bottom, 20)
        }
        .background(Color.themeBackground.ignoresSafeArea())
    }
}

#Preview {
    RootFeatureView(
        store: .init(
            initialState: .init(),
            reducer: {
                RootFeature()
            }
        )
    )
}
