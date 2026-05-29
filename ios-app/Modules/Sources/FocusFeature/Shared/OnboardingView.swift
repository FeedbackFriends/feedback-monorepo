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
                    title: "Improve recurring meetings",
                    subtitle: "Collect lightweight feedback after the meetings your team already runs."
                )
                .tag(0)
                OnboardingPage(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Ask the right questions",
                    subtitle: "Use short meeting feedback that is easy for participants to answer."
                )
                .tag(1)
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track meeting quality",
                    subtitle: "See whether recurring meetings improve, stay flat, or need attention."
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
                Text(page == 2 ? "Get Started" : "Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if page < 2 {
                Button("Skip") {
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
                    Text("Which meeting should collect feedback?")
                        .titleTextStyle()

                    Text("Start with one recurring meeting. You can adjust questions later.")
                        .foregroundStyle(Color.themeTextSecondary)
                        .multilineTextAlignment(.center)
                }

                TextField("e.g. Weekly team sync", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button {
                    // Normally you'd save this
                    dismiss()
                    onComplete()
                } label: {
                    Text("Create my first recurring meeting")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Get Started")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    OnboardingView {
        print("Finished onboarding")
    }
}
