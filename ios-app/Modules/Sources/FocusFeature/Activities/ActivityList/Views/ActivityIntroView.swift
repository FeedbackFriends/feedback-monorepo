import DesignSystem
import SwiftUI

struct ActivityIntroSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                introBody
                    .padding()
            }
            .navigationTitle("Hvad er en aktivitet?")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
        }
    }

    private var introBody: some View {
        ActivityIntroContentView()
            .accessibilityIdentifier("my_activity_intro_text")
    }
}

struct ActivityIntroContentView: View {
    private let examples: [(emoji: String, text: String)] = [
        ("🎤", "Et foredrag om ledelse"),
        ("🤖", "En AI-workshop"),
        ("🎾", "En padeltræning"),
        ("📅", "Det månedlige teammøde")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(
                """
                En 'Aktivitet' er et format, du gentager. Noget, du løbende ønsker at forbedre gennem feedback og \
                erfaringer.

                Det kunne være:
                """
            )
            .bodyTextStyle()
            .foregroundStyle(Color.themeText)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(examples, id: \.text) { example in
                    HStack(alignment: .top, spacing: 10) {
                        Text(example.emoji)
                        Text(example.text)
                            .bodyTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
            }

            Text("\nTryk på plus-knappen for at oprette din første aktivitet.")
                .bodyTextStyle()
                .foregroundStyle(Color.themeText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}
