import Localization
import SwiftUI
import Domain
import DesignSystem

struct QuestionPickerView: View {

    let existingQuestionID: EventInput.QuestionInput.ID?
    let questionSelected: (_ input: EventInput.QuestionInput) -> Void
    var text: String {
        if existingQuestionID != nil {
            String(appStrings: .questionsSaveChange)
        } else {
            String(appStrings: .questionsAdd)
        }
    }
    var navigationTitle: String {
        if existingQuestionID != nil {
            String(appStrings: .questionsEdit)
        } else {
            String(appStrings: .questionsNewTitle)
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
        self._isChoosingFeedbackType = State(initialValue: false)
        self._questionTextField = State(initialValue: questionTextField)
        self.questionSelected = questionSelected
    }

    private var isQuestionValid: Bool {
        feedbackTypeSelected != nil && !questionTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func commitQuestion() {
        let trimmed = questionTextField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let feedbackTypeSelected, !trimmed.isEmpty else { return }
        var input = EventInput.QuestionInput(questionText: trimmed, feedbackType: feedbackTypeSelected)
        if let existingQuestionID {
            input.id = existingQuestionID
        }
        questionSelected(input)
        dismiss()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    questionSection
                    answerTypeSection
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
            SectionHeaderView(String(appStrings: .commonQuestions))

            TextInputView(
                title: String(appStrings: .questionsInputTitle),
                prompt: String(appStrings: .questionsInputPrompt),
                text: $questionTextField,
                isFocused: $isQuestionFocused,
                axis: .vertical,
                lineLimit: 2...6,
                accessibilityLabel: String(appStrings: .commonQuestions),
                accessibilityIdentifier: "question_editor_input"
            )
        }
    }

    private var answerTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(String(appStrings: .questionsAnswerType))
            Button {
                isQuestionFocused = false
                isChoosingFeedbackType = true
            } label: {
                HStack(spacing: 12) {
                    if let feedbackTypeSelected {
                        feedbackTypeSelected.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(Color.themePrimaryAction)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feedbackTypeSelected.title).rowTitleTextStyle()
                            Text(feedbackTypeSelected.shortDescription).supportingTextStyle()
                        }
                    } else {
                        Text(String(appStrings: .questionsAnswerHelp)).supportingTextStyle()
                    }
                    Spacer()
                    Text(String(appStrings: feedbackTypeSelected == nil ? .commonChoose : .commonChange))
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themePrimaryAction)
                }
                .surfaceCard(padding: 15)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("question_editor_change_type")
        }
        .sheet(isPresented: $isChoosingFeedbackType) {
            QuestionAnswerTypePickerView(
                selectedType: feedbackTypeSelected,
                questionText: questionTextField
            ) { feedbackTypeSelected = $0 }
        }
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
