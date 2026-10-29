import SwiftUI
import DesignSystem
import ComposableArchitecture

struct StartFeedbackConfirmationView: View {
    
    @Environment(\.dismiss) var dismiss
    let startFeedback: () -> Void
   
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Session fundet")
                    .titleTextStyle()
                    .accessibilityAddTraits(.isHeader)
                Text("Sessionen er fundet. Vil du svare nu?")
                    .bodyTextStyle()
                Button("Svar på feedback") {
                    startFeedback()
                    dismiss()
                }
                .buttonStyle(LargeBoxButtonStyle(color: Color.themePrimaryAction))
                Button("Ikke nu") {
                    dismiss()
                }
                .buttonStyle(LargeBoxButtonStyle(style: .secondary))
            }
            .foregroundStyle(Color.themeText)
            .padding(24)
        }
        .presentationBackground(Color.themeBackground)
    }
}

#Preview {
    StartFeedbackConfirmationView(startFeedback: {})
}

#Preview {
    @Previewable @State var showStartFeedbackConfirmation: Bool = false
    Button("Show start feedback confirmation") {
        showStartFeedbackConfirmation = true
    }
    .sheet(isPresented: $showStartFeedbackConfirmation) {
        StartFeedbackConfirmationView(startFeedback: {})
            .presentationDetents([.height(300)])
    }
}
