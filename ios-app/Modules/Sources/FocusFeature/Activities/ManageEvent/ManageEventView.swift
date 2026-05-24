import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct ManageEventView: View {

    @Bindable var store: StoreOf<ManageEvent>

    public init(store: StoreOf<ManageEvent>) {
        self.store = store
    }

    public var body: some View {
        EventFormView(
            showSuccessOverlay: $store.showSuccessOverlay,
            store: store.scope(state: \.eventForm, action: \.eventForm)
        ) {
            Button(store.actionButtonTitle) {
                store.send(.actionButtonTap)
            }
            .buttonStyle(PrimaryTextButtonStyle())
            .isLoading(store.manageEventInFlight)
            .disabled(store.manageEventButtonDisabled)
        }
        .navigationBarTitle(store.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
