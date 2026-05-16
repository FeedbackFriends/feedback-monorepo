import SwiftUI
import DesignSystem
import Domain
import FeedbackFlowFeature
import ComposableArchitecture

// MARK: - View

public struct CreateActivityView: View {
    @Bindable var store: StoreOf<CreateActivity>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<CreateActivity>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    detailsSection
                    runModeSection
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
            .navigationTitle("Create Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .sheet(isPresented: $store.showInfoSheet) {
                AutomaticInfoSheet(email: store.botEmail)
            }
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
                        Text("Preview")
                            .font(.montserratSemiBold, 12)
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
                    recentlyUsedQuestions: [],
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

private extension CreateActivityView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
                .buttonStyle(SecondaryTextButtonStyle())
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(store.createActivityRequestInFlight ? "Creating..." : "Create") {
                store.send(.createButtonTapped)
            }
            .accessibilityIdentifier("create_activity_submit")
            .buttonStyle(PrimaryTextButtonStyle())
            .disabled(store.isCreateDisabled)
        }
        .sharedBackgroundVisibility(.hidden)
    }

    var detailsSection: some View {
        section(title: "Details") {
            inputField(
                title: "Activity title",
                prompt: "What do you want feedback on?",
                text: $store.title,
                accessibilityIdentifier: "create_activity_title_input"
            )

            sectionDivider

            inputField(
                title: "Context",
                prompt: "Add context (optional)",
                text: $store.description,
                axis: .vertical,
                lineLimit: 2...4
            )
        }
    }

    var runModeSection: some View {
        section(title: "How it runs") {
            VStack(spacing: 12) {
                ForEach(RunMode.allCases) { mode in
                    SelectableRow(
                        title: mode.title,
                        subtitle: mode.subtitle,
                        icon: mode.icon,
                        isSelected: store.selectedRunMode == mode
                    ) {
                        store.selectedRunMode = mode
                    }
                }
            }

            if store.selectedRunMode == .automatic {
                sectionDivider
                automaticSetup
            }
        }
    }

    var feedbackSection: some View {
        section(
            title: "How feedback works",
            footer: "Templates give you a starting point. The question list stays editable."
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
                    Text("Choose one feedback type")
                        .font(.montserratRegular, 13)
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
            title: "Questions",
            footer: store.selectedTemplate == .buildYourOwn && store.questions.isEmpty
                ? "Add at least one question before creating the activity."
                : nil
        ) {
            Button {
                store.showQuestionsList = true
            } label: {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.questionsSectionTitle)
                                .font(.montserratSemiBold, 15)
                                .foregroundStyle(Color.themeText)
                            Text(store.questionsSectionSubtitle)
                                .font(.montserratRegular, 13)
                                .foregroundStyle(Color.themeTextSecondary)
                        }

                        Spacer()

                        Image.chevronRight
                            .foregroundStyle(Color.themeTextSecondary)
                    }

                    if store.questions.isEmpty {
                        Text("No questions yet. Tap to add your first question.")
                            .font(.montserratRegular, 13)
                            .foregroundStyle(Color.themeTextSecondary)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(store.questions.prefix(3))) { question in
                                HStack(alignment: .top, spacing: 10) {
                                    Image.checkmarkCircleFill
                                        .foregroundStyle(Color.themePrimaryAction)
                                        .font(.caption)

                                    Text(question.questionText)
                                        .font(.montserratRegular, 13)
                                        .foregroundStyle(Color.themeTextSecondary)
                                        .multilineTextAlignment(.leading)
                                }
                            }

                            if store.questions.count > 3 {
                                Text("+\(store.questions.count - 3) more questions")
                                    .font(.montserratRegular, 12)
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
                Text("Select a template to start building questions.")
                    .font(.montserratRegular, 13)
                    .foregroundStyle(Color.themeTextSecondary)
            } else {
                Text("You can review, edit, add, and reorder questions.")
                    .font(.montserratRegular, 13)
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }

    var automaticSetup: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create sessions automatically")
                .font(.montserratSemiBold, 15)

            Text("Invite this email to your calendar event")
                .font(.montserratRegular, 13)
                .foregroundStyle(Color.themeTextSecondary)

            HStack(spacing: 12) {
                Text(store.botEmail)
                    .font(.montserratSemiBold, 12)
                    .foregroundStyle(Color.themeText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.themeBackground.opacity(0.9), in: Capsule())

                Spacer(minLength: 0)

                Button {
                    UIPasteboard.general.string = store.botEmail
                    store.send(.copyBotEmailTapped)
                } label: {
                    HStack(spacing: 6) {
                        Image.documentOnDocument
                        Text("Copy")
                    }
                }
                .buttonStyle(PrimaryTextButtonStyle())
            }

            if store.didCopyEmail {
                Text("Email copied. Paste it into your calendar event.")
                    .font(.montserratRegular, 12)
                    .foregroundStyle(Color.themeTextSecondary)
            }

            Button("How it works") {
                store.showInfoSheet = true
            }
            .buttonStyle(SecondaryTextButtonStyle())
        }
    }

    @ViewBuilder
    func section<Content: View>(
        title: String,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .sectionHeaderStyle()
                .padding(.leading, 4)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(Theme.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .lightShadow()

            if let footer {
                Text(footer)
                    .font(.montserratRegular, 12)
                    .foregroundStyle(Color.themeTextSecondary)
                    .padding(.horizontal, 4)
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
                .font(.montserratMedium, 13)
                .foregroundStyle(Color.themeTextSecondary)

            TextField(
                "",
                text: text,
                prompt: Text(prompt)
                    .foregroundStyle(Color.themeTextSecondary),
                axis: axis
            )
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
            .font(.montserratRegular, 15)
            .foregroundStyle(Color.themeText)
            .lineLimit(lineLimit ?? 1...1)
        }
    }

    var sectionDivider: some View {
        Rectangle()
            .fill(Color.themeBackground.opacity(0.9))
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
                        .font(.montserratSemiBold, 15)
                        .foregroundStyle(Color.themeText)
                    Text(subtitle)
                        .font(.montserratRegular, 13)
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
            .background(Color.themeBackground.opacity(isSelected ? 0.95 : 0.65))
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
                        .font(.montserratSemiBold, 15)
                        .foregroundStyle(Color.themeText)

                    Text(template.subtitle)
                        .font(.montserratRegular, 13)
                        .foregroundStyle(Color.themeTextSecondary)
                }

                Spacer()

                Button(action: onClear) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.themeTextSecondary)
                        .frame(width: 30, height: 30)
                        .background(Color.themeBackground.opacity(0.9), in: Circle())
                }
                .accessibilityLabel("Clear selected feedback type")
                .buttonStyle(.plain)
            }

            Button("Edit questions", action: onEditQuestions)
                .buttonStyle(SecondaryTextButtonStyle())
        }
        .padding(.horizontal, Theme.padding)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeBackground.opacity(0.95))
        .overlay {
            Capsule(style: .continuous)
                .stroke(Color.themePrimaryAction, lineWidth: 1.5)
        }
        .clipShape(Capsule(style: .continuous))
    }
}

//
// MARK: - Info Sheet
//

struct AutomaticInfoSheet: View {
    let email: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.padding) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Use automatic sessions when you already run meetings from a calendar invite.")
                            .font(.montserratRegular, 14)
                            .foregroundStyle(Color.themeTextSecondary)

                        infoStep(
                            title: "1. Add the bot email",
                            detail: "Invite \(email) to the calendar event you already use."
                        )
                        infoStep(
                            title: "2. We create the session",
                            detail: "A new feedback activity is prepared automatically from the calendar event."
                        )
                        infoStep(
                            title: "3. Feedback is sent after",
                            detail: "Participants receive feedback when the event is done."
                        )
                    }
                    .padding(Theme.padding)
                    .frame(maxWidth: Constants.maxWidthForLargeDevices, alignment: .leading)
                    .background(Color.themeSurface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    .lightShadow()

                    Button("Copy email") {
                        UIPasteboard.general.string = email
                    }
                    .buttonStyle(LargeButtonStyle())
                    .frame(maxWidth: Constants.maxWidthForLargeDevices)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Theme.padding)
                .padding(.top, Theme.padding)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .foregroundStyle(Color.themeText)
            .navigationTitle("Automatic sessions")
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
                    .font(.montserratSemiBold, 15)
                Text(detail)
                    .font(.montserratRegular, 13)
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
    }
}

//
// MARK: - Enums
//

public enum RunMode: String, CaseIterable, Identifiable, Sendable {
    case manual, automatic
    public var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: return "Standard"
        case .automatic: return "Automatic"
        }
    }

    var subtitle: String {
        switch self {
        case .manual: return "Create session one ny one"
        case .automatic: return "Use your calendar"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "hand.tap"
        case .automatic: return "envelope.badge"
        }
    }
}

public enum FeedbackTemplate: String, CaseIterable, Identifiable, Sendable {
    case quickFeedback
    case engagement
    case learning
    case retrospective
    case leadership
    case buildYourOwn

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .quickFeedback: return "Quick feedback"
        case .engagement: return "Engagement"
        case .learning: return "Learning"
        case .retrospective: return "Retrospective"
        case .leadership: return "Leadership"
        case .buildYourOwn: return "Build your own"
        }
    }

    var subtitle: String {
        switch self {
        case .quickFeedback:
            return "Fast rating with optional comment"
        case .engagement:
            return "Energy and participation"
        case .learning:
            return "Clarity and usefulness"
        case .retrospective:
            return "Reflect and improve as a team"
        case .leadership:
            return "Feedback on leadership and direction"
        case .buildYourOwn:
            return "Start empty and write every question yourself"
        }
    }

    var icon: String {
        switch self {
        case .quickFeedback: return "bolt"
        case .engagement: return "person.2"
        case .learning: return "lightbulb"
        case .retrospective: return "arrow.clockwise"
        case .leadership: return "person.crop.circle.badge.checkmark"
        case .buildYourOwn: return "square.and.pencil"
        }
    }

    var defaultQuestions: [EventInput.QuestionInput] {
        switch self {
        case .quickFeedback:
            return [
                .init(questionText: "How was this session?", feedbackType: .emoji),
                .init(questionText: "What went well?", feedbackType: .comment),
                .init(questionText: "What could be improved?", feedbackType: .comment)
            ]

        case .engagement:
            return [
                .init(questionText: "How was the energy?", feedbackType: .emoji),
                .init(questionText: "Did you feel involved?", feedbackType: .opinion),
                .init(questionText: "What affected engagement?", feedbackType: .comment)
            ]

        case .learning:
            return [
                .init(questionText: "How clear was it?", feedbackType: .zeroToTen),
                .init(questionText: "How useful was it?", feedbackType: .zeroToTen),
                .init(questionText: "What is still unclear?", feedbackType: .comment)
            ]

        case .retrospective:
            return [
                .init(questionText: "What worked well?", feedbackType: .comment),
                .init(questionText: "What could be better?", feedbackType: .comment),
                .init(questionText: "Overall rating", feedbackType: .zeroToTen)
            ]

        case .leadership:
            return [
                .init(questionText: "Did you feel well guided?", feedbackType: .opinion),
                .init(questionText: "Was communication clear?", feedbackType: .opinion),
                .init(questionText: "What could be improved in leadership?", feedbackType: .comment)
            ]

        case .buildYourOwn:
            return []
        }
    }
}

struct FocusPreviewSession: Equatable, Sendable, Identifiable {
    let id = UUID()
    let state: FeedbackFlowCoordinator.State
}

private extension ActivityInput.RunMode {
    init(_ runMode: RunMode) {
        switch runMode {
        case .manual:
            self = .manual
        case .automatic:
            self = .automatic
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

#Preview {
    CreateActivityView(
        store: Store(initialState: .init()) {
            CreateActivity()
        }
    )
}
