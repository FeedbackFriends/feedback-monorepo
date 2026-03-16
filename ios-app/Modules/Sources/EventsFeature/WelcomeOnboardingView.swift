import DesignSystem
import SwiftUI

public struct WelcomeOnboardingView: View {
    let accountEmail: String?
    let primaryButtonTitle: String
    let primaryAction: () -> Void

    public init(
        accountEmail: String?,
        primaryButtonTitle: String = "Back to My sessions",
        primaryAction: @escaping () -> Void
    ) {
        self.accountEmail = accountEmail
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
    }

    public var body: some View {
        ZStack {
            backgroundView
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    stepsSection
                    integrationsSection
                    emailSection
                    primaryButton
                }
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.padding)
                .padding(.vertical, 32)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private extension WelcomeOnboardingView {
    var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.themeSurface)
                    .overlay(
                        Circle()
                            .stroke(Color.themeTextSecondary.opacity(0.15), lineWidth: 1)
                    )
                    .lightShadow()
                Image.letsGrowIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            .frame(width: 70, height: 70)
            Text("How My sessions works")
                .font(.montserratBold, 28)
                .foregroundStyle(Color.themeText.gradient)
                .multilineTextAlignment(.center)
        }
    }

    var stepsSection: some View {
        VStack(spacing: 12) {
            featureRow(
                title: Text("Create your meeting invite")
                    .foregroundStyle(Color.themeText),
                message: Text("Use your favorite calendar as you already do (Google, Outlook, Apple Calendar, or Teams).")
                    .foregroundStyle(Color.themeTextSecondary),
                icon: Image.calendar
            )
            featureRow(
                title: inviteFeedbackTitle,
                message: Text("That is the only extra step. We will handle the rest and your draft appears in My sessions."),
                icon: Image.sparkles
            )
            featureRow(
                title: Text("Open My sessions and customize")
                    .foregroundStyle(Color.themeText),
                message: Text("Add questions and choose if participants get an email invite or an in-app notification.")
                    .foregroundStyle(Color.themeTextSecondary),
                icon: Image.documentOnDocument
            )
        }
    }

    var emailSection: some View {
        VStack(spacing: 10) {
            Text("Calendar account email")
                .font(.montserratSemiBold, 12)
                .foregroundStyle(Color.themeTextSecondary)
            Text(emailDisplay)
                .font(.montserratSemiBold, 14)
                .foregroundStyle(Color.themeText)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.themeSurfaceSecondary)
                )
            Text("This must match the account you use to send calendar invites.")
                .font(.montserratRegular, 12)
                .foregroundStyle(Color.themeTextSecondary)
            Text("You can update it anytime in Profile.")
                .font(.montserratRegular, 12)
                .foregroundStyle(Color.themeTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            glassBackground(in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Color.themeTextSecondary.opacity(0.12), lineWidth: 1)
        )
        .lightShadow()
    }

    var integrationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Works with")
                .sectionHeaderStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140), spacing: 12, alignment: .leading)],
                alignment: .leading,
                spacing: 12
            ) {
                integrationBadge(label: "Google Calendar", icon: Image.iconGoogle, isTemplate: false)
                integrationBadge(label: "Microsoft Outlook", icon: Image.iconMicrosoft, isTemplate: false)
                integrationBadge(label: "Apple Calendar", icon: Image.iconApple, isTemplate: true)
                integrationBadge(label: "Teams", icon: Image.iconApple, isTemplate: true)
            }
        }
    }

    var primaryButton: some View {
        Button(primaryButtonTitle) {
            primaryAction()
        }
        .buttonStyle(LargeButtonStyle())
    }

    var backgroundView: some View {
        ZStack {
            Color.themeBackground
            LinearGradient(
                colors: [
                    Color.themeGradientBlue.opacity(0.18),
                    Color.themeGradientRed.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.themeGradientBlue.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: -140, y: -160)
            Circle()
                .fill(Color.themeGradientRed.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 150, y: 180)
        }
        .ignoresSafeArea()
    }

    func featureRow(title: Text, message: Text, icon: Image) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.themeSurfaceSecondary)
                icon
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.themePrimaryAction)
            }
            .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 4) {
                title
                    .font(.montserratSemiBold, 14)
                message
                    .font(.montserratRegular, 12)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Color.themeSurface)
        )
        .lightShadow()
    }

    func integrationBadge(label: String, icon: Image, isTemplate: Bool) -> some View {
        HStack(spacing: 8) {
            if isTemplate {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(Color.themeText)
            } else {
                icon
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            Text(label)
                .font(.montserratSemiBold, 12)
                .foregroundStyle(Color.themeText)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Color.themeSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(Color.themeTextSecondary.opacity(0.12), lineWidth: 1)
        )
        .lightShadow()
    }

    @ViewBuilder
    func glassBackground<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            shape
                .fill(Color.clear)
                .glassEffect(.regular, in: shape)
        } else {
            shape
                .fill(.ultraThinMaterial)
        }
    }

    var emailDisplay: String {
        guard let accountEmail, !accountEmail.isEmpty else {
            return "you@company.com"
        }
        return accountEmail
    }

    var feedbackEmailText: Text {
        Text("feedback@letsgrow.dk")
            .foregroundStyle(Color.themeSuccess)
    }

    var inviteFeedbackTitle: Text {
        Text("Add ").foregroundStyle(Color.themeText)
            + feedbackEmailText
            + Text(" to your calendar invite").foregroundStyle(Color.themeText)
    }
}

#Preview {
    WelcomeOnboardingView(accountEmail: "hello@letsgrow.dk", primaryAction: {})
}
