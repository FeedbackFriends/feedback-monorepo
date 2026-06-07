import DesignSystem
import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0
    @State private var showCreateActivity = false

    var body: some View {
        VStack {
            TabView(selection: $page) {
                OnboardingPage(
                    icon: "leaf.fill",
                    title: "Forbedr aktiviteter",
                    subtitle: "Indsaml kort feedback efter teamets møder, workshops og træning."
                )
                .tag(0)
                OnboardingPage(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Stil få gode spørgsmål",
                    subtitle: "Gør det nemt for deltagerne at svare, mens oplevelsen stadig er frisk."
                )
                .tag(1)
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Følg feedback over tid",
                    subtitle: "Se om aktiviteten bliver bedre, står stille eller kræver handling."
                )
                .tag(2)
            }
            .tabViewStyle(.page)

            bottomControls
        }
        .padding()
        .sheet(isPresented: $showCreateActivity) {
            FirstRecurringMeetingOnboardingView {
                onFinish()
            }
        }
    }
    private var bottomControls: some View {
        VStack(spacing: 12) {
            Button {
                if page < 2 {
                    page += 1
                } else {
                    showCreateActivity = true
                }
            } label: {
                Text(page == 2 ? "Kom i gang" : "Fortsæt")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if page < 2 {
                Button("Spring over") {
                    showCreateActivity = true
                }
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }
}
struct OnboardingPage: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image.onboardingIcon(icon)
                .foregroundStyle(Color.themeSuccess)

            VStack(spacing: 12) {
                Text(title)
                    .titleTextStyle()

                Text(subtitle)
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}
struct FirstRecurringMeetingOnboardingView: View {
    var onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image.firstFocusOnboardingIcon
                    .foregroundStyle(Color.themeSuccess)

                VStack(spacing: 8) {
                    Text("Hvilken aktivitet skal have feedback?")
                        .titleTextStyle()

                    Text("Start med én aktivitet. Du kan justere spørgsmålene senere.")
                        .foregroundStyle(Color.themeTextSecondary)
                        .multilineTextAlignment(.center)
                }

                TextField("fx Ugentlig team sync", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button {
                    // Normally you'd save this
                    dismiss()
                    onComplete()
                } label: {
                    Text("Opret min første aktivitet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Kom i gang")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    OnboardingView {
        print("Finished onboarding")
    }
}
