import TabbarFeature
import ComposableArchitecture
import SwiftUI
import DesignSystem
import SignUpFeature

public struct RootFeatureView: View {
    
    @Bindable var store: StoreOf<RootFeature>
    
    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            switch store.destination {
                
            case .isLoading:
                LoadingView()
                
            case .signUp:
                signUpView
                
            case let .error(errorType):
                errorView(errorType)
                
            case .loggedIn:
                loggedInView
            }
        }
		.tint(Color.themePrimaryAction)
        .animation(.linear(duration: 0.8), value: store.destination)
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

struct LoadingView: View {
    @State var didLoad: Bool = false
    var body: some View {
        VStack {
            if didLoad {
                LottieView(lottieFile: .loading, loopMode: true)
                    .frame(width: 400, height: 50)
                Text("Loading data")
                    .padding(.top, 20)
                    .font(.montserratRegular, 16)
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground.ignoresSafeArea())
        .onAppear {
            didLoad = true
        }
        .animation(.linear(duration: 0.3), value: didLoad)
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
