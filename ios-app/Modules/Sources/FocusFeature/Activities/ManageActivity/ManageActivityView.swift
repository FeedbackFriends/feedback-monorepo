import SwiftUI
import DesignSystem
import Domain
import FeedbackFlowFeature
import ComposableArchitecture
import Utility

public struct ManageActivityView: View {
    @Bindable var store: StoreOf<ManageActivity>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<ManageActivity>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    detailsSection
                    feedbackSection
                    questionsSection
                }
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .padding(.horizontal, Theme.padding)
                .padding(.top, Theme.padding)
                .padding(.bottom, Theme.padding)
                .frame(maxWidth: .infinity)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .foregroundStyle(Color.themeText)
            .navigationTitle(store.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .sheet(item: $store.previewSession) { previewSession in
                FeedbackFlowCoordinatorView(
                    store: Store(
                        initialState: previewSession.state
                    ) {
                        FeedbackFlowCoordinator()
                            .transformDependency(\.apiClient) { apiClient in
                                apiClient.submitFeedback = { _, _ in false }
                                return ()
                            }
                    },
                    principalToolbarItem: {
                        Text("Forhåndsvis")
                            .captionTextStyle()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.themeBlue.gradient)
                            .foregroundStyle(Color.themeOnPrimaryAction)
                            .clipShape(Capsule())
                    }
                )
            }
            .navigationDestination(isPresented: $store.showQuestionsList) {
                QuestionsListView(
                    questionsInputs: $store.questions,
                    previewConfiguration: .init(
                        title: store.title,
                        agenda: store.description.nilIfBlank,
                        presentFeedbackFlowSession: { feedbackSessionState in
                            store.previewSession = .init(state: feedbackSessionState)
                        }
                    )
                )
            }
        }
    }
}

private extension ManageActivityView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            CloseButtonView { dismiss() }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(store.actionButtonTitle) {
                store.send(.actionButtonTap)
            }
            .accessibilityIdentifier("create_activity_submit")
            .buttonStyle(PrimaryTextButtonStyle())
            .isLoading(store.createActivityRequestInFlight)
            .disabled(store.isCreateDisabled)
        }
        .sharedBackgroundVisibility(.hidden)
    }

    var detailsSection: some View {
        section(title: "1. Detaljer") {
            inputField(
                title: "Aktivitetens navn",
                prompt: "Fx månedligt teammøde, workshop eller træning",
                text: $store.title,
                accessibilityIdentifier: "create_activity_title_input"
            )

            sectionDivider

            inputField(
                title: "Kontekst eller agenda",
                prompt: "Skriv kontekst, agenda eller formål (valgfrit)",
                text: $store.description,
                axis: .vertical,
                lineLimit: 2...4
            )
        }
    }

    var feedbackSection: some View {
        section(
            title: "2. Feedbackskabelon",
            footer: "Du kan tilpasse spørgsmålene i næste trin."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(FeedbackTemplate.allCases) { template in
                    SelectableRow(
                        title: template.title,
                        subtitle: template.subtitle,
                        icon: template.icon,
                        isSelected: store.selectedTemplate == template,
                        accessibilityIdentifier: "create_activity_template_\(template.rawValue)"
                    ) {
                        store.send(.templateSelected(template))
                    }
                }
            }
        }
    }

    var questionsSection: some View {
        section(
            title: "3. Spørgsmål",
            footer: store.selectedTemplate == .customQuestions && store.questions.isEmpty
                ? "Tilføj mindst ét spørgsmål, før du opretter aktiviteten."
                : nil
        ) {
            Button {
                store.showQuestionsList = true
            } label: {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.questionsSectionTitle)
                                .rowTitleTextStyle()
                                .foregroundStyle(Color.themeText)
                            Text(store.questionsSectionSubtitle)
                                .supportingTextStyle()
                                .foregroundStyle(Color.themeTextSecondary)
                        }

                        Spacer()

                        Image.chevronRight
                            .foregroundStyle(Color.themeTextSecondary)
                    }

                    if store.questions.isEmpty {
                        Text("Ingen spørgsmål endnu. Tryk for at tilføje det første.")
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(store.questions.prefix(3))) { question in
                                QuestionSummaryRow(question: question)
                            }

                            if store.questions.count > 3 {
                                Text("+\(store.questions.count - 3) flere spørgsmål")
                                    .supportingTextStyle()
                                    .foregroundStyle(Color.themeTextSecondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .disabled(store.selectedTemplate == nil)
            .opacity(store.selectedTemplate == nil ? 0.6 : 1.0)

            if store.selectedTemplate == nil {
                Text("Vælg først en skabelon.")
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }

    @ViewBuilder
    func section<Content: View>(
        title: String,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            SectionHeaderView(title)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))

            if let footer {
                Text(footer)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
            }
        }
    }

    @ViewBuilder
    func inputField(
        title: String,
        prompt: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        accessibilityIdentifier: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .rowTitleTextStyle()
                .foregroundStyle(Color.themeText)

            TextField(
                "",
                text: text,
                prompt: Text(prompt)
                    .foregroundStyle(Color.themeTextSecondary),
                axis: axis
            )
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
            .supportingTextStyle()
            .foregroundStyle(Color.themeText)
            .lineLimit(lineLimit ?? 1...1)
        }
    }

    var sectionDivider: some View {
        Rectangle()
            .fill(Color.themeBackground)
            .frame(height: 1)
    }
}

//
// MARK: - Supporting Views
//

private struct SelectableRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let accessibilityIdentifier: String?
    let onTap: () -> Void

    init(
        title: String,
        subtitle: String,
        icon: String,
        isSelected: Bool,
        accessibilityIdentifier: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(isSelected ? Color.themePrimaryAction : Color.themeTextSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themeText)
                    Text(subtitle)
                        .supportingTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                }

                Spacer()

                Group {
                    if isSelected {
                        Image.checkmarkCircleFill
                    } else {
                        Image.circle
                    }
                }
                .foregroundStyle(isSelected ? Color.themePrimaryAction : Color.themeTextSecondary)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeBackground)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(isSelected ? Color.themePrimaryAction : Color.clear, lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .buttonStyle(ScalingButtonStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct QuestionSummaryRow: View {
    let question: EventInput.QuestionInput

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            FeedbackTypeTagView(question.feedbackType)

            Text(question.questionText)
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .multilineTextAlignment(.leading)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ManageActivityView(
        store: Store(initialState: ManageActivity.State.create()) {
            ManageActivity()
        }
    )
}
