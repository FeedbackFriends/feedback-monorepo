import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI

public struct EditEventView: View {
    
    @Bindable var store: StoreOf<EditEvent>
    @Environment(\.dismiss) var dismiss
    
    public init(store: StoreOf<EditEvent>) {
        self.store = store
    }
    
    public var body: some View {
        EventFormView(
            showSuccessOverlay: $store.showSuccessOverlay,
            store: store.scope(state: \.eventForm, action: \.eventForm),
            action: {
                Button("Save") {
                    store.send(.editEventButtonTap)
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .isLoading(store.editRequestInFlight)
                .disabled(store.editEventButtonDisabled)
            }
        )
        .navigationBarTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
