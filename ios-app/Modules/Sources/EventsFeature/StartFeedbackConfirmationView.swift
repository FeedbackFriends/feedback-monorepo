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
                        Text("Feedback is ready. Would you like to start now? 🙏🏼")
                    }
                    .font(.montserratRegular, 14)
                    VStack(alignment: .center, spacing: 12) {
                        
                        Button("Start feedback") {
                            startFeedback()
                            dismiss()
                        }
                        .buttonStyle(LargeBoxButtonStyle(color: Color.themePrimaryAction))
                        
                        Button("Not now") {
                            dismiss()
                        }
                        .buttonStyle(LargeBoxButtonStyle(style: .secondary))
                    }
                }
                .padding(.horizontal, 18)
                .navigationTitle("Feedback ready")
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
