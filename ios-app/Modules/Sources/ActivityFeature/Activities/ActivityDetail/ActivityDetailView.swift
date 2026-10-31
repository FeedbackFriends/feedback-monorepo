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
                Color.themeBackground.ignoresSafeArea()
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.showDeleteConfirmation,
                action: \.destination.showDeleteConfirmation
            ),
            onDismiss: { store.send(.deleteConfirmationDismissed) }
        ) { _ in
            DeleteConfirmationViewSheet(
                title: "Slet aktivitet",
                message: "Slet denne aktivitet og al feedback?",
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
            if let activity = store.activity {
                ActivityDetailHowItWorksSheetView(activityEmail: activity.activityEmail) {
                    UIPasteboard.general.string = activity.activityEmail
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}
