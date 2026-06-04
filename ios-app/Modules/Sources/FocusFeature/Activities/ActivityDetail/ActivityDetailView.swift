import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ActivityDetailView: View {
    @Bindable var store: StoreOf<ActivityDetail>

    var body: some View {
        Group {
            if let activity = store.activity {
                ActivityDetailContentView(store: store, activity: activity)
            } else {
                EmptyView()
                    .successOverlay(
                        message: "Aktivitet slettet",
                        show: .constant(true),
                        enableAutomaticDismissal: true
                    )
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.showDeleteConfirmation,
                action: \.destination.showDeleteConfirmation
            )
        ) { _ in
            DeleteConfirmationViewSheet(
                title: "Slet aktivitet",
                message: "Slet dette faste møde og al feedback?",
                actionButton: {
                    Button("Slet") {
                        store.send(.deleteActivityConfirmButtonTap)
                    }
                    .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                    .isLoading(store.deleteActivityInFlight)
                }
            )
            .presentationDetents([.height(340)])
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.showHowItWorks,
                action: \.destination.showHowItWorks
            )
        ) { _ in
            ActivityDetailHowItWorksSheetView {
                UIPasteboard.general.string = "feedback@letsgrow.dk"
            }
            .presentationDetents([.medium, .large])
        }
    }
}
