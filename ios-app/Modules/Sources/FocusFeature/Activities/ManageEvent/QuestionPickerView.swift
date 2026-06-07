import SwiftUI
import Domain
import DesignSystem

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
    @State var feedbackTypeSelected: FeedbackType
    @State var questionTextField: String
    @State private var showFeedbackInfo = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isQuestionFocused: Bool

    init(
        existingQuestionID: EventInput.QuestionInput.ID?,
        feedbackTypeSelected: FeedbackType,
        questionTextField: String,
        questionSelected: @escaping (_ input: EventInput.QuestionInput) -> Void
    ) {
        self.existingQuestionID = existingQuestionID
        self._feedbackTypeSelected = State(initialValue: feedbackTypeSelected)
        self._questionTextField = State(initialValue: questionTextField)
        self.questionSelected = questionSelected
    }

    private var isQuestionValid: Bool {
        !questionTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func commitQuestion() {
        Task {
            withAnimation {
                dismiss()
            }
            try await Task.sleep(for: .seconds(0.3))
            let trimmed = questionTextField.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
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
                VStack(alignment: .leading, spacing: 18) {
                    Section {
                        VStack(spacing: 8) {
                            ForEach(FeedbackType.allCases, id: \.self) { type in
                                let isSelected = type == feedbackTypeSelected
                                Button {
                                    withAnimation {
                                        feedbackTypeSelected = type
                                    }
                                } label: {
                                    FeedbackTypeOptionView(type: type, isSelected: isSelected)
                                }
                                .buttonStyle(ScalingButtonStyle())
                                .accessibilityLabel(type.title)
                                .accessibilityHint(type.helpDescription)
                            }
                        }
                        .background(Color.themeBackground)

                        SelectedFeedbackTypeView(type: feedbackTypeSelected)
                    } header: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                SectionHeaderView("Svartype", horizontalPadding: 0)
                                Spacer()
                                Button {
                                    showFeedbackInfo = true
                                } label: {
                                    Image.info
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(Color.themeText)
                                        .padding(8)
                                        .background(Color.themeSurface)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(ScalingButtonStyle())
                                .accessibilityLabel("Læs om svartyper")
                            }
                            Text("Vælg hvordan deltagerne skal svare på spørgsmålet.")
                                .supportingTextStyle()
                                .foregroundStyle(Color.themeTextSecondary)
                        }
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("Skriv spørgsmålet", text: $questionTextField, axis: .vertical)
                                .focused($isQuestionFocused)
                                .bodyTextStyle()
                                .foregroundColor(Color.themeText)
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.go)
                                .lineLimit(3...6)
                                .padding(.trailing, questionTextField.isEmpty ? 0 : 28)
                                .overlay(alignment: .topTrailing) {
                                    if !questionTextField.isEmpty {
                                        Button {
                                            questionTextField = ""
                                        } label: {
                                            Image.xmarkCircleFill
                                                .foregroundStyle(Color.themeTextSecondary)
                                        }
                                        .foregroundStyle(Color.themeTextSecondary)
                                        .padding(.top, 2)
                                    }
                                }
                            Text("Skriv kort og konkret. Gode spørgsmål er nemme at svare på lige efter sessionen.")
                                .supportingTextStyle()
                                .foregroundStyle(Color.themeTextSecondary)
                        }
                        .padding(Theme.padding)
                        .background(Color.themeSurface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    } header: {
                        SectionHeaderView("Spørgsmål", horizontalPadding: 0)
                    }

                    Button(text, action: commitQuestion)
                        .buttonStyle(LargeButtonStyle())
                        .disabled(!isQuestionValid)
                        .padding(.bottom, 18)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .sensoryFeedback(.selection, trigger: feedbackTypeSelected)
                .sheet(isPresented: $showFeedbackInfo) {
                    FeedbackTypeInfoSheetView()
                }
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        self.dismiss()
                    }
                }
            }
            .onAppear {
                isQuestionFocused = true
            }
            .background {
                /// this makes the keyboard to appear with a single animation
                FirstResponderFieldView()
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .background(Color.themeSurface.ignoresSafeArea())
            }
        }
    }
}

private struct FeedbackTypeOptionView: View {
    let type: FeedbackType
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            type.image
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(isSelected ? Color.themeOnPrimaryAction : Color.themePrimaryAction)
                .padding(9)
                .background(isSelected ? Color.themePrimaryAction : Color.themePrimaryAction.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(type.title)
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
                Text(type.shortDescription)
                    .captionTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
            }

            Spacer(minLength: 0)

            Image.checkmarkCircleFill
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(isSelected ? Color.themePrimaryAction : Color.clear)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(isSelected ? Color.themeSurface : Color.themeSurface.opacity(0.58))
        .clipShape(Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .stroke(isSelected ? Color.themePrimaryAction.opacity(0.65) : Color.clear, lineWidth: 2)
        }
    }
}

private struct SelectedFeedbackTypeView: View {
    let type: FeedbackType

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            type.image
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(Color.themePrimaryAction)
                .padding(8)
                .background(Color.themePrimaryAction.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text("Valgt: \(type.title)")
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
                Text(type.helpDescription)
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .animation(.default, value: type)
    }
}

#Preview("Empty - Create") {
    QuestionPickerView(
        existingQuestionID: nil,
        feedbackTypeSelected: .emoji,
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
