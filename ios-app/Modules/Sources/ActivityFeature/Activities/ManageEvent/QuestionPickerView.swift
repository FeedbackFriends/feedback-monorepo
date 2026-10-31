import SwiftUI
import Domain
import DesignSystem
import FeedbackFlowFeature

struct QuestionPickerView: View {

    let existingQuestionID: EventInput.QuestionInput.ID?
    let questionSelected: (_ input: EventInput.QuestionInput) -> Void
    var text: String {
        if existingQuestionID != nil {
            "Gem ændring"
        } else {
            "Tilføj spørgsmål"
        }
    }
    var navigationTitle: String {
        if existingQuestionID != nil {
            "Rediger spørgsmål"
        } else {
            "Nyt spørgsmål"
        }
    }
    @State private var feedbackTypeSelected: FeedbackType?
    @State private var questionTextField: String
    @State private var isChoosingFeedbackType: Bool
    @Environment(\.dismiss) private var dismiss
    #if DEBUG
    @Environment(\.isScreenSnapshot) private var isScreenSnapshot
    #endif
    @FocusState private var isQuestionFocused: Bool

    init(
        existingQuestionID: EventInput.QuestionInput.ID?,
        feedbackTypeSelected: FeedbackType? = nil,
        questionTextField: String,
        questionSelected: @escaping (_ input: EventInput.QuestionInput) -> Void
    ) {
        self.existingQuestionID = existingQuestionID
        self._feedbackTypeSelected = State(initialValue: feedbackTypeSelected)
        self._isChoosingFeedbackType = State(initialValue: feedbackTypeSelected == nil)
        self._questionTextField = State(initialValue: questionTextField)
        self.questionSelected = questionSelected
    }

    private var isQuestionValid: Bool {
        feedbackTypeSelected != nil && !questionTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func commitQuestion() {
        let trimmed = questionTextField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let feedbackTypeSelected, !trimmed.isEmpty else { return }
        Task {
            withAnimation {
                dismiss()
            }
            try await Task.sleep(for: .seconds(0.3))
            var input = EventInput.QuestionInput(questionText: trimmed, feedbackType: feedbackTypeSelected)
            if let existingQuestionID {
                input.id = existingQuestionID
            }
            withAnimation {
                questionSelected(input)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    questionSection
                    answerTypeSection
                    if let feedbackTypeSelected {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView("Sådan ser deltagerne det")
                            FeedbackQuestionIllustrationView(
                                questionText: questionTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? "Dit spørgsmål vises her" : questionTextField,
                                feedbackType: feedbackTypeSelected
                            )
                            .id(feedbackTypeSelected)
                        }
                    }
                }
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.themeBackground.ignoresSafeArea())
            .foregroundStyle(Color.themeText)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button(text, action: commitQuestion)
                    .buttonStyle(LargeButtonStyle())
                    .disabled(!isQuestionValid)
                    .padding(Theme.padding)
                    .frame(maxWidth: .infinity)
                    .background(Color.themeBackground)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButtonView { dismiss() }
                }
            }
            .sensoryFeedback(.selection, trigger: feedbackTypeSelected)
            .onAppear {
                #if DEBUG
                isQuestionFocused = !isScreenSnapshot
                #else
                isQuestionFocused = true
                #endif
            }
            .background {
                /// This makes the keyboard appear with a single animation.
                FirstResponderFieldView()
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .background(Color.themeSurface.ignoresSafeArea())
            }
        }
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView("Spørgsmål")

            TextInputView(
                title: "Hvad vil du gerne vide?",
                prompt: "Fx hvor nyttigt var mødet for dig?",
                text: $questionTextField,
                isFocused: $isQuestionFocused,
                axis: .vertical,
                lineLimit: 2...6,
                accessibilityLabel: "Spørgsmål",
                accessibilityIdentifier: "question_editor_input"
            )
        }
    }

    private var answerTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView("Svartype")

            VStack(alignment: .leading, spacing: 12) {
                if let feedbackTypeSelected {
                    Button {
                        isQuestionFocused = false
                        isChoosingFeedbackType.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            feedbackTypeSelected.image
                                .foregroundStyle(Color.themePrimaryAction)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feedbackTypeSelected.title)
                                    .rowTitleTextStyle()
                                Text(feedbackTypeSelected.shortDescription)
                                    .supportingTextStyle()
                                    .foregroundStyle(Color.themeTextSecondary)
                            }
                            Spacer()
                            Text(isChoosingFeedbackType ? "Luk" : "Skift")
                                .foregroundStyle(Color.themePrimaryAction)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("question_editor_change_type")
                } else {
                    Text("Vælg hvordan deltagerne skal svare.")
                        .rowTitleTextStyle()
                        .padding(15)
                }

                if isChoosingFeedbackType {
                    VStack(spacing: 12) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            SelectionOptionRowView(
                                title: type.title,
                                subtitle: type.shortDescription,
                                icon: type.image,
                                isSelected: type == feedbackTypeSelected,
                                accessibilityIdentifier: "question_editor_type_\(type.rawValue)"
                            ) {
                                isQuestionFocused = false
                                feedbackTypeSelected = type
                                isChoosingFeedbackType = false
                            }
                            .accessibilityHint(type.helpDescription)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
                    .transition(.blurReplace)
                }
            }
            .surfaceCard(padding: 0)
        }
        .animation(.smooth, value: isChoosingFeedbackType)
    }
}

#Preview("Empty - Create") {
    QuestionPickerView(
        existingQuestionID: nil,
        questionTextField: "",
        questionSelected: { _ in }
    )
}

#Preview("Empty - Edit") {
    QuestionPickerView(
        existingQuestionID: UUID(),
        feedbackTypeSelected: .emoji,
        questionTextField: "",
        questionSelected: { _ in }
    )
}

#Preview("Long input") {
    QuestionPickerView(
        existingQuestionID: nil,
        feedbackTypeSelected: .emoji,
        questionTextField: "Aslkdjska lsak slksak sakaksl kaskask sa kask sak sak as k kask as kask kas kask ask ask k as kas k sdjdsjds sd js djs sjd",
        questionSelected: { _ in }
    )
}
