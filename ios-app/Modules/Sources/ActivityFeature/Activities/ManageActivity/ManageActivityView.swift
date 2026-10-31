import SwiftUI
import DesignSystem
import Domain
import ComposableArchitecture
import Utility

public struct ManageActivityView: View {
    @Bindable var store: StoreOf<ManageActivity>
    @Environment(\.dismiss) private var dismiss
    #if DEBUG
    @Environment(\.isScreenSnapshot) private var isScreenSnapshot
    #endif
    @FocusState private var isTitleFocused: Bool

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

    }
}

private extension ManageActivityView {
    var detailsStep: some View {
        stepPage {
            if store.mode == .create {
                stepHeader(number: 1, title: "Giv aktiviteten et navn")
            }
            detailsSection
            if store.mode == .edit {
                feedbackSection
            }
        }
        .task {
            guard store.mode == .create, store.path.isEmpty else { return }
            #if DEBUG
            guard !isScreenSnapshot else { return }
            #endif
            isTitleFocused = true
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
            stepHeader(number: 2, title: "Vælg feedbackskabelon", subtitle: "Vælg et udgangspunkt, og tilpas spørgsmålene til din aktivitet.")
            feedbackSection
        }
        .safeAreaInset(edge: .bottom) { submitButton }
    }

    var questionsStep: some View {
        QuestionsListView(
            questionsInputs: $store.questions
        )
        .background(Color.themeBackground.ignoresSafeArea())
        .toolbar { closeButton }
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

    func stepHeader(number: Int, title: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trin \(number) af 2")
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
            Text(title)
                .titleTextStyle()
            if let subtitle {
                Text(subtitle)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
            isTitleFocused = false
            store.send(.nextButtonTap)
            if store.isTitleMissing { isTitleFocused = true }
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
            if store.isTitleMissing { isTitleFocused = true }
        }
        .accessibilityIdentifier("create_activity_submit")
        .buttonStyle(LargeButtonStyle())
        .isLoading(store.createActivityRequestInFlight)
        .disabled(store.isSubmitDisabled)
        .padding(Theme.padding)
        .background(Color.themeBackground)
    }

    var detailsSection: some View {
        VStack(alignment: .leading) {
            if store.mode == .edit {
                SectionHeaderView("Aktivitet")
            }

            TextInputView(
                title: "Aktivitetens navn",
                prompt: "Fx månedligt teammøde, workshop eller træning",
                text: $store.title,
                isFocused: $isTitleFocused,
                accessibilityIdentifier: "create_activity_title_input"
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
                    SelectionOptionRowView(
                        title: template.title,
                        subtitle: template.subtitle,
                        icon: Image(systemName: template.icon),
                        isSelected: store.selectedTemplate == template,
                        accessibilityIdentifier: "create_activity_template_\(template.rawValue)"
                    ) {
                        store.send(.templateSelected(template))
                    }
                }
                .transition(.blurReplace)
            }

            if store.selectedTemplate != nil {
                sectionDivider
                questionsSection
            }
        }
        .animation(.smooth, value: store.isChoosingTemplate)
    }

    var questionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(store.questions) { question in
                Text(question.questionText)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeText)
                    .multilineTextAlignment(.leading)
            }

            Button {
                store.path.append(.questions)
            } label: {
                Label(store.questions.isEmpty ? "Tilføj spørgsmål" : "Rediger spørgsmål",
                      systemImage: store.questions.isEmpty ? "plus" : "pencil")
            }
            .buttonStyle(InlineActionButtonStyle())
            .accessibilityIdentifier("create_activity_questions")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func section<Content: View>(
        title: String?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            if let title {
                SectionHeaderView(title)
            }

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
    }

    var sectionDivider: some View {
        Rectangle()
            .fill(Color.themeBackground)
            .frame(height: 1)
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
