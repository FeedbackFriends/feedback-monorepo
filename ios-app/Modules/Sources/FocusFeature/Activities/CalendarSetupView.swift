import DesignSystem
import SwiftUI

struct CalendarSetupView: View {
    let email: String
    let didCopyEmail: Bool
    let onCopyEmail: () -> Void
    let onCreateOneOffSession: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    init(
        email: String,
        didCopyEmail: Bool,
        onCopyEmail: @escaping () -> Void,
        onCreateOneOffSession: (() -> Void)? = nil
    ) {
        self.email = email
        self.didCopyEmail = didCopyEmail
        self.onCopyEmail = onCopyEmail
        self.onCreateOneOffSession = onCreateOneOffSession
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Inviter denne mail til din faste kalenderaftale.")
                            .bodyTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)

                        HStack(spacing: 12) {
                            Text(email)
                                .rowTitleTextStyle()
                                .foregroundStyle(Color.themeText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Spacer(minLength: 0)

                            Button("Kopiér") {
                                onCopyEmail()
                            }
                            .buttonStyle(PrimaryTextButtonStyle())
                        }
                        .padding(Theme.padding)
                        .background(Color.themeBackground, in: Capsule(style: .continuous))

                        if didCopyEmail {
                            Text("Mailen er kopieret. Sæt den ind i den faste kalenderaftale.")
                                .supportingTextStyle()
                                .foregroundStyle(Color.themeTextSecondary)
                        }

                        infoStep(
                            title: "1. Tilføj mailen",
                            detail: "Inviter \(email) til den kalenderaftale, du allerede bruger."
                        )
                        infoStep(
                            title: "2. Hold mødet som normalt",
                            detail: "LetsGrow opretter feedback ud fra den faste kalenderaftale."
                        )
                        infoStep(
                            title: "3. Se udviklingen",
                            detail: "Deltagerne får feedback efter mødet, og du kan følge om mødet bliver bedre."
                        )

                        if let onCreateOneOffSession {
                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Alternativ")
                                    .sectionHeaderStyle()
                                Text("Hvis du bare vil oprette en enkelt mødegang uden kalenderopsætning.")
                                    .supportingTextStyle()
                                    .foregroundStyle(Color.themeTextSecondary)
                            }

                            Button("Opret enkelt mødegang") {
                                onCreateOneOffSession()
                            }
                            .buttonStyle(SecondaryTextButtonStyle())
                        }
                    }
                    .padding(Theme.padding)
                    .frame(maxWidth: Constants.maxWidthForLargeDevices, alignment: .leading)
                    .background(Color.themeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    .lightShadow()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.padding)
                .padding(.top, Theme.padding)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .foregroundStyle(Color.themeText)
            .navigationTitle("Kalenderopsætning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
        }
    }

    private func infoStep(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image.checkmarkCircleFill
                .foregroundStyle(Color.themePrimaryAction)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .rowTitleTextStyle()
                Text(detail)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }
}
