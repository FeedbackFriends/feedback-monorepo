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
                    title: "Grow with feedback",
                    subtitle: "Turn everyday moments into opportunities to improve."
                )
                .tag(0)
                OnboardingPage(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Get insights from others",
                    subtitle: "Ask for feedback after meetings, workshops, or presentations."
                )
                .tag(1)
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track your progress",
                    subtitle: "See how you improve over time with clear trends."
                )
                .tag(2)
            }
            .tabViewStyle(.page)

            bottomControls
        }
        .padding()
        .sheet(isPresented: $showCreateActivity) {
            FirstFocusOnboardingView {
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
                .font(.subheadline)
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

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.themeSuccess)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title.bold())

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(Color.themeTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}
struct FirstFocusOnboardingView: View {
    var onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "leaf.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.themeSuccess)

                VStack(spacing: 8) {
                    Text("What do you want to grow?")
                        .font(.title.bold())

                    Text("Start by choosing something you'd like feedback on.")
                        .foregroundStyle(Color.themeTextSecondary)
                        .multilineTextAlignment(.center)
                }

                TextField("e.g. My leadership in meetings", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button {
                    // Normally you'd save this
                    dismiss()
                    onComplete()
                } label: {
                    Text("Create my first activity")
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
