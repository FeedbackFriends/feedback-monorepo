import DesignSystem
import SwiftUI

struct ActivityDetailHowItWorksView: View {
    let onCopyEmail: () -> Void
    @State private var showCopiedAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Fra kalender til feedback")
                    .titleTextStyle()
                    .foregroundStyle(Color.themeText)

                Text(
                    """
                    Brug det kalenderværktøj, du allerede \
                    planlægger i, og inviter blot 'Lets Grow'-mailen. Så oprettes sessionen automatisk her i appen.
                    """
                )
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text(
                    """
                    Invitationen skal sendes fra mailadressen på din \
                    LetsGrow-konto, navn@firma.dk. Du kan ændre den under Profil.
                    """
                )
                    .bodyTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)

                CalendarIntegrationsView()

                HStack(spacing: 12) {
                    Text(verbatim: "feedback@letsgrow.dk")
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themeText)
                        .tint(Color.themeText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    Button("Kopiér") {
                        onCopyEmail()
                        showCopiedAlert = true
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                }
                .padding(Theme.padding)
                .background(Color.themeBackground, in: Capsule(style: .continuous))
            }

            Divider()

            Text("Du kan også oprette en session manuelt i Mere-menuen, hvis du foretrækker det.")
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .alert("Mailen er kopieret", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sæt den ind i den kalenderaftale, du allerede bruger.")
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
