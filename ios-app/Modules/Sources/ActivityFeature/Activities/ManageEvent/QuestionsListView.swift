import SwiftUI
import Domain
import DesignSystem
import FeedbackFlowFeature
import ComposableArchitecture

struct QuestionsListView: View {
    
    @Binding var questionsInputs: [EventInput.QuestionInput]
    @State private var presentSelectQuestionSheet: EventInput.QuestionInput?
    @State private var existingQuestionID: EventInput.QuestionInput.ID?
    let onPreview: ((FeedbackFlowCoordinator.State) -> Void)?
    
    init(
        questionsInputs: Binding<[EventInput.QuestionInput]>,
        onPreview: ((FeedbackFlowCoordinator.State) -> Void)? = nil
    ) {
        self._questionsInputs = questionsInputs
        self.onPreview = onPreview
    }
    
    var body: some View {
        Group {
            if questionsInputs.isEmpty {
                EmptyStateView(
                    title: "Ingen spørgsmål",
                    message: "Tryk '+' for at tilføje et spørgsmål"
                ).frame(maxHeight: .infinity)
            } else {
                Form {
                    ForEach(questionsInputs) { questionsInput in
                        Button {
                            self.existingQuestionID = questionsInput.id
                            self.presentSelectQuestionSheet = questionsInput
                        } label: {
                            HStack(spacing: 12) {
                                FeedbackTypeTagView(questionsInput.feedbackType, style: .iconOnly)

                                Text(questionsInput.questionText)
                                    .foregroundStyle(Color.themeText)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        questionsInputs.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        questionsInputs.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }
        }
        .navigationTitle("Spørgsmål")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.themeBackground.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .supportingTextStyle()
        .foregroundColor(Color.themeTextSecondary)
        .sheet(
            item: $presentSelectQuestionSheet,
            content: { questionInput in
                QuestionPickerView(
                    existingQuestionID: self.existingQuestionID,
                    feedbackTypeSelected: questionInput.feedbackType,
                    questionTextField: questionInput.questionText
                ) { selectedQuestionInput in
                    if let index = self.questionsInputs.firstIndex(where: { $0.id == selectedQuestionInput.id }) {
                        self.questionsInputs[index] = selectedQuestionInput
                    } else {
                        self.questionsInputs.append(selectedQuestionInput)
                    }
                }
            }
        )
        .safeAreaInset(
            edge: .bottom,
            content: {
                HStack(spacing: 6) {
                    if let onPreview {
                        Button {
                            onPreview(
                                .initialState(
                                    feedbackSession: .init(
                                        questions: self.questionsInputs.map {
                                            ParticipantQuestion(
                                                id: $0.id,
                                                questionText: $0.questionText,
                                                feedbackType: $0.feedbackType
                                            )
                                        },
                                        ownerInfo: OwnerInfo(
                                            name: nil,
                                            email: nil,
                                            phoneNumber: nil
                                        ),
                                        pinCode: PinCode(value: "None"),
                                        date: Date()
                                    )
                                )
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image.playButton
                                    Text("Forhåndsvis session")
                                }
                                Text("Sådan oplever deltagerne feedbacken.")
                                    .captionTextStyle()
                            }
                        }
                        .buttonStyle(LargeBoxButtonStyle())
                        .opacity(self.questionsInputs.isEmpty ? 0.6 : 1.0)
                        .disabled(self.questionsInputs.isEmpty)
                    }
                    Spacer()
                    Button {
                        self.existingQuestionID = nil
                        self.presentSelectQuestionSheet = .init(questionText: "", feedbackType: .emoji)
                    } label: {
                        Image.circleFill
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.themePrimaryAction.gradient)
                            .overlay {
                                Image.plus
                                    .frame(width: 26, height: 26)
                                    .foregroundStyle(Color.themeOnPrimaryAction)
                                    .fontWeight(.semibold)
                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.themeBackground)
            }
        )
    }
}

#Preview {
    NavigationStack {
        QuestionsListView(
            questionsInputs: .constant(
                [
                    .init(
                        questionText: "hjddshjd dshdh sdjhsd dshds hdhs h dsh dsh dsh dhs h dsh ds hhds hsd hsdhdsh ds",
                        feedbackType: .emoji
                    )
                ]
            ),
            onPreview: { _ in }
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        QuestionsListView(
            questionsInputs: .constant([]),
            onPreview: { _ in }
        )
    }
}
