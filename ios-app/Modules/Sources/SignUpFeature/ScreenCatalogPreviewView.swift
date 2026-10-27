#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

@MainActor
private func catalogSignInReady() -> some View {
    ScreenCatalogContainerView {
        SignUpView(store: Store(initialState: SignUp.State()) { EmptyReducer() })
    }
}

#Preview("sign-in.ready") {
    catalogSignInReady()
}

@MainActor
private func catalogSignInAppleLoading() -> some View {
    ScreenCatalogContainerView {
        SignUpView(store: Store(initialState: SignUp.State(appleLoginInFlight: true)) { EmptyReducer() })
    }
}

#Preview("sign-in.apple-loading") {
    catalogSignInAppleLoading()
}

@MainActor
private func catalogSignInGoogleLoading() -> some View {
    ScreenCatalogContainerView {
        SignUpView(store: Store(initialState: SignUp.State(googleLoginInFlight: true)) { EmptyReducer() })
    }
}

#Preview("sign-in.google-loading") {
    catalogSignInGoogleLoading()
}

private func catalogSignInErrorState() -> SignUp.State {
    var state = SignUp.State()
    state.destination = .alert(AlertState<Never> {
        TextState("Login mislykkedes")
    } actions: {
        ButtonState(role: .cancel) { TextState("OK") }
    } message: {
        TextState("Prøv at logge ind igen.")
    })
    return state
}

@MainActor
private func catalogSignInError() -> some View {
    ScreenCatalogContainerView {
        SignUpView(store: Store(initialState: catalogSignInErrorState()) { EmptyReducer() })
    }
}

#Preview("sign-in.error") {
    catalogSignInError()
}

@MainActor
private func catalogAccountTypeUnselected() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = SelectUserType.State()
            state.selectedUserType = nil
            state.isLoading = false
            return state
        }()
        NavigationStack {
            SelectUserTypeView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("account-type.unselected") {
    catalogAccountTypeUnselected()
}

@MainActor
private func catalogAccountTypeManager() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = SelectUserType.State()
            state.selectedUserType = .manager
            state.isLoading = false
            return state
        }()
        NavigationStack {
            SelectUserTypeView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("account-type.manager") {
    catalogAccountTypeManager()
}

@MainActor
private func catalogAccountTypeParticipant() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = SelectUserType.State()
            state.selectedUserType = .participant
            state.isLoading = false
            return state
        }()
        NavigationStack {
            SelectUserTypeView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("account-type.participant") {
    catalogAccountTypeParticipant()
}

@MainActor
private func catalogAccountTypeSaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = SelectUserType.State()
            state.selectedUserType = .manager
            state.isLoading = true
            return state
        }()
        NavigationStack {
            SelectUserTypeView(store: Store(initialState: state) { EmptyReducer() })
        }
    }
}

#Preview("account-type.saving") {
    catalogAccountTypeSaving()
}

#endif
