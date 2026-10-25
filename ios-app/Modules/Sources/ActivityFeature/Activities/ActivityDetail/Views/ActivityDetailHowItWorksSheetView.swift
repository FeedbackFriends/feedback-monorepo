import DesignSystem
import SwiftUI

struct ActivityDetailHowItWorksSheetView: View {
    let activityEmail: String
    let onCopyEmail: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                ActivityDetailHowItWorksView(activityEmail: activityEmail, onCopyEmail: onCopyEmail)
                    .padding(Theme.padding)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}
