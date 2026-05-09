//
//  OnboardingView.swift
//  Modules
//
//  Created by Nicolai Dam on 18/03/2026.
//


import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0
    @State private var showCreateFocus = false

    var body: some View {
        VStack {
            TabView(selection: $page) {

                // MARK: - Page 1
                OnboardingPage(
                    icon: "leaf.fill",
                    title: "Grow with feedback",
                    subtitle: "Turn everyday moments into opportunities to improve."
                )
                .tag(0)

                // MARK: - Page 2
                OnboardingPage(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Get insights from others",
                    subtitle: "Ask for feedback after meetings, workshops, or presentations."
                )
                .tag(1)

                // MARK: - Page 3
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
        .sheet(isPresented: $showCreateFocus) {
            FirstFocusOnboardingView {
                onFinish()
            }
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            Button {
                if page < 2 {
                    page += 1
                } else {
                    showCreateFocus = true
                }
            } label: {
                Text(page == 2 ? "Get Started" : "Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if page < 2 {
                Button("Skip") {
                    showCreateFocus = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Onboarding Page

struct OnboardingPage: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.green)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title.bold())

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}

// MARK: - First Focus (Activation Screen)

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
                    .foregroundStyle(.green)

                VStack(spacing: 8) {
                    Text("What do you want to grow?")
                        .font(.title.bold())

                    Text("Start by choosing something you'd like feedback on.")
                        .foregroundStyle(.secondary)
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
                    Text("Create my first focus")
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

// MARK: - Preview

#Preview {
    OnboardingView {
        print("Finished onboarding")
    }
}