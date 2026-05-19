import SwiftUI
import DesignSystem
import ComposableArchitecture

struct DeleteConfirmationView: View {
    @Bindable var store: StoreOf<DeleteConfirmation>
    
    public init(store: StoreOf<DeleteConfirmation>) {
        self.store = store
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Are you sure you want to delete the event?")
                            .font(.montserratRegular, 14)
                    }
                    VStack(alignment: .center, spacing: 12) {
                        
                        Button("Delete") {
                            store.send(.deleteButtonTap)
                        }
                        .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                        .isLoading(store.deleteEventInFlight)
                        
                        Button("Cancel") {
                            store.send(.cancelButtonTap)
                        }
                        .buttonStyle(LargeBoxButtonStyle(style: .secondary))
                    }
                }
                .padding(.horizontal, 18)
                .navigationTitle("Delete")
                .navigationBarTitleDisplayMode(.large)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        store.send(.cancelButtonTap)
                    }
                }
            }
        }
        .successOverlay(
            message: "Session deleted",
            show: $store.showSuccessOverlay
        )
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview {
    DeleteConfirmationView(
        store: .init(
            initialState: .init(eventId: UUID()),
            reducer: { DeleteConfirmation()
            }
        )
    )
}

#Preview {
    @Previewable @State var showDeleteConfirmation: Bool = false
    Button("Delete") {
        showDeleteConfirmation = true
    }
    .sheet(isPresented: $showDeleteConfirmation) {
        DeleteConfirmationView(
            store: .init(
                initialState: .init(eventId: UUID()),
                reducer: {
                    DeleteConfirmation()
                }
            )
        )
    }
}
