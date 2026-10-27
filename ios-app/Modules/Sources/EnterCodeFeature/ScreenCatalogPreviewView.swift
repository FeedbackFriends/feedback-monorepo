#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

@MainActor
private func catalogFeedbackCodePartial() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            EnterCodeView(store: Store(initialState: EnterCode.State(
                pinCodeInput: .init(value: "12"), startFeedbackPincodeInFlight: false
            )) { EmptyReducer() })
        }
    }
}

#Preview("feedback-code.partial") {
    catalogFeedbackCodePartial()
}

@MainActor
private func catalogFeedbackCodeReady() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            EnterCodeView(store: Store(initialState: EnterCode.State(
                pinCodeInput: .init(value: "1234"), startFeedbackPincodeInFlight: false
            )) { EmptyReducer() })
        }
    }
}

#Preview("feedback-code.ready") {
    catalogFeedbackCodeReady()
}

@MainActor
private func catalogFeedbackCodeLoading() -> some View {
    ScreenCatalogContainerView {
        NavigationStack {
            EnterCodeView(store: Store(initialState: EnterCode.State(
                pinCodeInput: .init(value: "1234"), startFeedbackPincodeInFlight: true
            )) { EmptyReducer() })
        }
    }
}

#Preview("feedback-code.loading") {
    catalogFeedbackCodeLoading()
}

#endif
