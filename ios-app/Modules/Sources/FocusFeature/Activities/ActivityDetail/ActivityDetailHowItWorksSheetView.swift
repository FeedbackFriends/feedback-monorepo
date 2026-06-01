import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ActivityDetailHowItWorksSheetView: View {
    let onCopyEmail: () -> Void
    @State private var showCopiedAlert = false

    var body: some View {
        ScrollView {
            ActivityDetailHowItWorksView(onCopyEmail: copyEmail)
        }
        .alert("Mailen er kopieret", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sæt den ind i den kalenderaftale, du allerede bruger.")
        }
    }

    private func copyEmail() {
        onCopyEmail()
        showCopiedAlert = true
    }
}

private struct HowItWorksStepView: View {
    let step: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.themePrimaryAction)
                    .frame(width: 24, height: 24)

                Text("\(step)")
                    .badgeTextStyle()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .rowTitleTextStyle()

                Text(description)
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }
}
