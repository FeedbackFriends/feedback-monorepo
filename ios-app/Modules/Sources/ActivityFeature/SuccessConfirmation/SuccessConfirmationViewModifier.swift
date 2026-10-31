import ComposableArchitecture
import DesignSystem
import SwiftUI

extension View {
    func successConfirmation(_ store: StoreOf<SuccessConfirmation>) -> some View {
        successMessage(store.message, isPresented: store.isPresented)
            .onNavigationTransitionCompleted { store.send(.transitionCompleted) }
    }
}
