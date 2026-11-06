import Localization
import DesignSystem
import SwiftUI

struct ActivityDetailHowItWorksView: View {
    let activityEmail: String
    let onCopyEmail: () -> Void
    @State private var showCopiedAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(appStrings: .activityCalendarSetupTitle))
                    .titleTextStyle()
                    .foregroundStyle(Color.themeText)

                Text(
                    String(appStrings: .activityCalendarSetupMessage)
                )
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(
                    String(appStrings: .activityCalendarAccountHelp)
                )
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)

                CalendarIntegrationsView()

                HStack(spacing: 12) {
                    Text(verbatim: activityEmail)
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themeText)
                        .tint(Color.themeText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    Button(String(appStrings: .commonCopy)) {
                        onCopyEmail()
                        showCopiedAlert = true
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                }
                .padding(Theme.padding)
                .background(Color.themeBackground, in: Capsule(style: .continuous))
            }

            Divider()

            Text(String(appStrings: .activityManualSessionHelp))
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard(padding: Theme.padding)
        .alert(String(appStrings: .activityCopyEmailTitle), isPresented: $showCopiedAlert) {
            Button(String(appStrings: .commonOk), role: .cancel) {}
        } message: {
            Text(String(appStrings: .activityCopyEmailMessage))
        }
    }
}

private struct CalendarIntegrationsView: View {
    private let integrations: [CalendarIntegration] = [
        CalendarIntegration(name: "Teams", image: .calendarTeamsLogo),
        CalendarIntegration(name: "Outlook", image: .calendarMicrosoftOutlook),
        CalendarIntegration(name: "Google", image: .calendarGoogle),
        CalendarIntegration(name: "Apple", image: .calendarAppleLogo),
        CalendarIntegration(name: "Zoho", image: .calendarZoho),
        CalendarIntegration(name: "Proton", image: .calendarProton)
    ]

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 44), spacing: 8),
        count: 6
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(integrations) { integration in
                VStack(spacing: 8) {
                    integration.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text(integration.name)
                        .captionTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(integration.name)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CalendarIntegration: Identifiable {
    let name: String
    let image: Image

    var id: String { name }
}
