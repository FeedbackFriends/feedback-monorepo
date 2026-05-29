import DesignSystem
import SwiftUI

struct CalendarSetupView: View {
    let email: String
    let didCopyEmail: Bool
    let onCopyEmail: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Invite this email to your recurring calendar event.")
                            .bodyTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)

                        HStack(spacing: 12) {
                            Text(email)
                                .rowTitleTextStyle()
                                .foregroundStyle(Color.themeText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Spacer(minLength: 0)

                            Button("Copy") {
                                onCopyEmail()
                            }
                            .buttonStyle(PrimaryTextButtonStyle())
                        }
                        .padding(Theme.padding)
                        .background(Color.themeBackground, in: Capsule(style: .continuous))

                        if didCopyEmail {
                            Text("Email copied. Paste it into the recurring calendar invite.")
                                .supportingTextStyle()
                                .foregroundStyle(Color.themeTextSecondary)
                        }

                        infoStep(
                            title: "1. Add the email",
                            detail: "Invite \(email) to the calendar event you already use."
                        )
                        infoStep(
                            title: "2. Run the meeting as usual",
                            detail: "LetsGrow creates feedback from the recurring calendar event."
                        )
                        infoStep(
                            title: "3. Review the trend",
                            detail: "Participants receive feedback after the meeting, and you can track whether it improves."
                        )
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
            .navigationTitle("Calendar setup")
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
