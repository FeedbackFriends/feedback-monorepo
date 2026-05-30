import SwiftUI
import DesignSystem
import ComposableArchitecture

struct StartFeedbackConfirmationView: View {
    
    @Environment(\.dismiss) var dismiss
    let startFeedback: () -> Void
   
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mødet er fundet. Vil du svare nu?")
                    }
                    .bodyTextStyle()
                    VStack(alignment: .center, spacing: 12) {
                        
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
                }
                .padding(.horizontal, 18)
                .navigationTitle("Møde fundet")
                .navigationBarTitleDisplayMode(.large)
                .foregroundStyle(Color.themeText)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        dismiss()
                    }
                }
            }
        }
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
