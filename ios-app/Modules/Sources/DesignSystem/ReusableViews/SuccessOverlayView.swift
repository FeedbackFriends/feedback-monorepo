import SwiftUI

struct SuccessOverlayView: View {
    
    let message: String
    @State private var showAlert = false
    @State private var alertDidAppear = false
    @State private var isModal = true
    @AccessibilityFocusState private var isFocused: Bool
    
    public var body: some View {
        content
            .onDisappear(perform: {
                self.isFocused = false
                self.isModal = false
            })
            .onChange(of: showAlert, { _, _ in
                if showAlert {
                    // A delay is needed here to get the accessibility focus working
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(0.2))
                        self.isFocused = true
                    }
                }
            })
    }
}

private extension SuccessOverlayView {
    
    var content: some View {
        ZStack {
            backgroundView
                .onAppear {
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(0.5))
                        withAnimation {
                            self.showAlert = true
                        }
                    }
                }
            if showAlert {
                alertView
                    .onAppear {
                        Task { @MainActor in
                            try await Task.sleep(for: .seconds(0.2))
                                withAnimation(.spring(response: 0.7, dampingFraction: 0.925, blendDuration: 10)) {
                                    alertDidAppear = true
                                }
                            try await Task.sleep(for: .seconds(0.6))
                        }
                    }
                    .sensoryFeedback(.success, trigger: alertDidAppear)
                    .transition(.opacity)
                    .padding(50)
                    .background(Color.themeBackground)
                    .cornerRadius(16)
            }
        }
    }
    
    var backgroundView: some View {
        Color.themeHoverOverlay
            .ignoresSafeArea()
    }
    
    var alertView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image.checkmarkCircleFill
                .resizable()
                .foregroundColor(Color.themeSuccess)
                .frame(width: 40, height: 40)
                .scaleEffect(alertDidAppear ? 1 : 0)
            Text(message)
                .font(.montserratBold, 18)
                .foregroundColor(Color.themeText)
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
        }
    }
}

#Preview {
    @Previewable @State var show = false
    Button("Test overlay") {
        show = true
    }
    .successOverlay(
        message: "Test banner",
        show: $show
    )
}
