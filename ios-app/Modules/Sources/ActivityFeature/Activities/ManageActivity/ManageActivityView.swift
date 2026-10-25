import SwiftUI
import DesignSystem
import Domain
import FeedbackFlowFeature
import ComposableArchitecture
import Utility

public struct ManageActivityView: View {
    @Bindable var store: StoreOf<ManageActivity>
    @Environment(\.dismiss) private var dismiss
    private enum Field: Hashable { case title, agenda }
    @FocusState private var focusedField: Field?

    public init(store: StoreOf<ManageActivity>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.path) {
            detailsStep
                .navigationDestination(for: ManageActivity.Step.self) { step in
                    switch step {
                    case .template:
                        templateStep
                    case .questions:
                        questionsStep
                    }
                }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .fullScreenCover(item: $store.scope(state: \.previewSession, action: \.previewSession)) { previewStore in
            FeedbackFlowCoordinatorView(
                store: previewStore,
                principalToolbarItem: {
                    Text("Forhåndsvisning")
                        .captionTextStyle()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.themeBlue.gradient)
                        .foregroundStyle(Color.themeOnPrimaryAction)
                        .clipShape(Capsule())
                }
            )
        }
    }
}

private extension ManageActivityView {
    var detailsStep: some View {
        stepPage {
            if store.mode == .create {
                stepHeader(number: 1, title: "Giv aktiviteten et navn", subtitle: "Brug et navn, du kan genkende, når du følger din feedback.")
            }
            detailsSection
            if store.mode == .edit {
                feedbackSection
            }
        }
        .safeAreaInset(edge: .bottom) {
            if store.mode == .create {
                nextButton
            } else {
                submitButton
            }
        }
    }

    var templateStep: some View {
        stepPage {
            stepHeader(number: 2, title: "Vælg feedbackskabelon", subtitle: "Vælg et udgangspunkt. Du kan tilpasse spørgsmålene i næste trin.")
            feedbackSection
        }
        .safeAreaInset(edge: .bottom) { nextButton }
    }

    var questionsStep: some View {
        VStack(spacing: 0) {
            if store.mode == .create {
                stepHeader(
                    number: 3,
                    title: "Tilpas dine spørgsmål",
                    subtitle: store.selectedTemplate == .customQuestions
                        ? "Tilføj de spørgsmål, du vil stille deltagerne."
                        : "Spørgsmålene kommer fra skabelonen “\(store.selectedTemplate?.title ?? "")”. Tryk på et spørgsmål for at ændre det."
                )
                .padding(Theme.padding)
            }
            QuestionsListView(
                questionsInputs: $store.questions,
                onPreview: { store.send(.previewRequested($0)) }
            )
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .toolbar { closeButton }
        .safeAreaInset(edge: .bottom) {
            if store.mode == .create {
                submitButton
            }
        }
    }

    func stepPage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24, content: content)
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .foregroundStyle(Color.themeText)
        .navigationTitle(store.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { closeButton }
    }

    func stepHeader(number: Int, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trin \(number) af 3")
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
            Text(title)
                .titleTextStyle()
            Text(subtitle)
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Color.themeText)
        .accessibilityElement(children: .combine)
    }

    @ToolbarContentBuilder
    var closeButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            CloseButtonView { dismiss() }
                .accessibilityIdentifier("create_activity_close")
        }
    }

    var nextButton: some View {
        Button("Videre") {
            focusedField = nil
            store.send(.nextButtonTap)
            if store.isTitleMissing { focusedField = .title }
        }
        .accessibilityIdentifier("create_activity_next")
        .buttonStyle(LargeButtonStyle())
        .disabled(store.isNextDisabled)
        .padding(Theme.padding)
        .background(Color.themeBackground)
    }

    var submitButton: some View {
        Button(store.mode == .create ? "Opret aktivitet" : store.actionButtonTitle) {
            store.send(.actionButtonTap)
            if store.isTitleMissing { focusedField = .title }
        }
        .accessibilityIdentifier("create_activity_submit")
        .buttonStyle(LargeButtonStyle())
        .isLoading(store.createActivityRequestInFlight)
        .disabled(store.isSubmitDisabled)
        .padding(Theme.padding)
        .background(Color.themeBackground)
    }

    var detailsSection: some View {
        section(title: "Aktivitet") {
            inputField(
                title: "Aktivitetens navn (påkrævet)",
                prompt: "Fx månedligt teammøde, workshop eller træning",
                text: $store.title,
                field: .title,
                accessibilityIdentifier: "create_activity_title_input"
            )

            sectionDivider

            inputField(
                title: "Kontekst eller agenda",
                prompt: "Skriv kontekst, agenda eller formål (valgfrit)",
                text: $store.description,
                field: .agenda,
                axis: .vertical,
                lineLimit: 2...4
            )
        }
    }

    var feedbackSection: some View {
        section(title: "Feedbackskabelon") {
            if let selectedTemplate = store.selectedTemplate {
                HStack(spacing: 12) {
                    Image(systemName: selectedTemplate.icon)
                        .foregroundStyle(Color.themePrimaryAction)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedTemplate.title)
                            .rowTitleTextStyle()
                        Text(selectedTemplate.subtitle)
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                    Spacer()
                    Button(store.isChoosingTemplate ? "Luk" : "Skift") {
                        store.send(.changeTemplateTapped)
                    }
                    .buttonStyle(SecondaryTextButtonStyle())
                    .accessibilityIdentifier("create_activity_change_template")
                }
            }

            if store.isChoosingTemplate {
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
                .transition(.blurReplace)
            }

            if store.mode == .edit && store.selectedTemplate != nil {
                sectionDivider
                questionsSection
            }
        }
        .animation(.smooth, value: store.isChoosingTemplate)
    }

    var questionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(store.selectedTemplate == .customQuestions ? "Dine spørgsmål"
                 : store.hasCustomizedQuestions ? "Dine tilpassede spørgsmål" : "Skabelonens spørgsmål")
                .rowTitleTextStyle()
            Button {
                store.path.append(.questions)
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

            if store.questions.isEmpty {
                Text("Tilføj mindst ét spørgsmål, før du opretter aktiviteten.")
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }

    @ViewBuilder
    func section<Content: View>(
        title: String,
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
        }
    }

    @ViewBuilder
    private func inputField(
        title: String,
        prompt: String,
        text: Binding<String>,
        field: Field,
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
            .focused($focusedField, equals: field)
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

#Preview("Navn") {
    ManageActivityView(
        store: Store(initialState: ManageActivity.State.create()) {
            ManageActivity()
        }
    )
}

#Preview("Skabelon") {
    ManageActivityView(
        store: Store(initialState: {
            var state = ManageActivity.State.create()
            state.title = "Ugentligt teammøde"
            state.path = [.template]
            return state
        }()) {
            ManageActivity()
        }
    )
}

#Preview("Spørgsmål") {
    ManageActivityView(
        store: Store(initialState: {
            var state = ManageActivity.State.create()
            state.title = "Ugentligt teammøde"
            state.selectTemplate(.standardMeeting)
            state.path = [.template, .questions]
            return state
        }()) {
            ManageActivity()
        }
    )
}
