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
                VStack(alignment: .leading, spacing: 8) {
                    detailsSection
                    feedbackSection
                        .padding(.top, 4)
                    questionsSection
                        .padding(.top, 4)
                }
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .padding(.horizontal, Theme.padding)
                .padding(.top, Theme.padding)
                .padding(.bottom, Theme.padding)
                .frame(maxWidth: .infinity)
            }
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
        section(title: "Detaljer") {
            inputField(
                title: "Navn på aktivitet",
                prompt: "Fx månedligt teammøde, workshop eller træning",
                text: $store.title,
                accessibilityIdentifier: "create_activity_title_input"
            )

            sectionDivider

            inputField(
                title: "Kontekst",
                prompt: "Skriv kontekst, agenda eller formål (valgfrit)",
                text: $store.description,
                axis: .vertical,
                lineLimit: 2...4
            )
        }
    }

    var feedbackSection: some View {
        section(
            title: "Feedback",
            footer: "Vælg en enkel start. Du kan altid tilpasse spørgsmålene bagefter."
        ) {
            if let selectedTemplate = store.selectedTemplate {
                SelectedFeedbackTemplateRow(
                    template: selectedTemplate,
                    onEditQuestions: {
                        store.showQuestionsList = true
                    },
                    onClear: {
                        store.send(.clearTemplateTapped)
                    }
                )
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vælg en feedbackskabelon")
                        .supportingTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)

                    ForEach(FeedbackTemplate.allCases) { template in
                        SelectableRow(
                            title: template.title,
                            subtitle: template.subtitle,
                            icon: template.icon,
                            isSelected: false,
                            accessibilityIdentifier: "create_activity_template_\(template.rawValue)"
                        ) {
                            store.send(.templateSelected(template))
                        }
                    }
                }
            }
        }
    }

    var questionsSection: some View {
        section(
            title: "Spørgsmål",
            footer: store.selectedTemplate == .customQuestions && store.questions.isEmpty
                ? "Tilføj mindst ét spørgsmål, før du opretter aktiviteten."
                : nil
        ) {
            Button {
                store.showQuestionsList = true
            } label: {
                VStack(alignment: .leading, spacing: 14) {
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
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(store.questions.prefix(3))) { question in
                                HStack(alignment: .top, spacing: 10) {
                                    Image.checkmarkCircleFill
                                        .captionTextStyle()
                                        .foregroundStyle(Color.themePrimaryAction)

                                    Text(question.questionText)
                                        .supportingTextStyle()
                                        .foregroundStyle(Color.themeTextSecondary)
                                        .multilineTextAlignment(.leading)
                                }
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
                Text("Vælg en skabelon for at få et godt udgangspunkt.")
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
            } else {
                Text("Du kan gennemse, redigere, tilføje og ændre rækkefølgen.")
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
            .cornerRadius(14)

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
                Capsule(style: .continuous)
                    .stroke(isSelected ? Color.themePrimaryAction : Color.clear, lineWidth: 1.5)
            }
            .clipShape(Capsule(style: .continuous))
        }
        .buttonStyle(ScalingButtonStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

private struct SelectedFeedbackTemplateRow: View {
    let template: FeedbackTemplate
    let onEditQuestions: () -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: template.icon)
                    .frame(width: 24)
                    .foregroundStyle(Color.themePrimaryAction)

                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themeText)

                    Text(template.subtitle)
                        .supportingTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                }

                Spacer()

                Button(action: onClear) {
                    Image.clearSelectionIcon
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.themeTextSecondary)
                        .frame(width: 30, height: 30)
                        .background(Color.themeBackground.opacity(0.9), in: Circle())
                }
                .accessibilityLabel("Ryd valgt mødeskabelon")
                .buttonStyle(.plain)
            }

            Button("Rediger spørgsmål", action: onEditQuestions)
                .buttonStyle(SecondaryTextButtonStyle())
        }
        .padding(.horizontal, Theme.padding)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeBackground)
        .overlay {
            Capsule(style: .continuous)
                .stroke(Color.themePrimaryAction, lineWidth: 1.5)
        }
        .clipShape(Capsule(style: .continuous))
    }
}

#Preview {
    ManageActivityView(
        store: Store(initialState: ManageActivity.State.create()) {
            ManageActivity()
        }
    )
}
