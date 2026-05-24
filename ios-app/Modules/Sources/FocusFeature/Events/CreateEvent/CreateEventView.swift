import ComposableArchitecture
import DesignSystem
import SwiftUI
import Domain

public struct CreateEventView: View {
    
    @Bindable var store: StoreOf<CreateEvent>
    
    public init(store: StoreOf<CreateEvent>) {
        self.store = store
    }
    
    public var body: some View {
        EventFormView(
            showSuccessOverlay: $store.showSuccessOverlay,
            store: store.scope(state: \.eventForm, action: \.eventForm)
        ) {
            Button("Save") {
                store.send(.createEventButtonTap)
            }
            .buttonStyle(PrimaryTextButtonStyle())
            .isLoading(store.manageActivityInFlight)
            .disabled(store.createEventButtonDisabled)
        }
        .navigationBarTitle("New")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
