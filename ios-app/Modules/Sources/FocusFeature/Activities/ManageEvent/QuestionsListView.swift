import SwiftUI
import Domain
import DesignSystem
import FeedbackFlowFeature
import ComposableArchitecture

struct QuestionsListView: View {
    
    struct PreviewConfiguration {
        let title: String
        let agenda: String?
        let presentFeedbackFlowSession: (FeedbackFlowCoordinator.State) -> Void
        
        init(
            title: String,
            agenda: String? = nil,
            presentFeedbackFlowSession: @escaping (FeedbackFlowCoordinator.State) -> Void
        ) {
            self.title = title
            self.agenda = agenda
            self.presentFeedbackFlowSession = presentFeedbackFlowSession
        }
    }
    
    @Binding var questionsInputs: [EventInput.QuestionInput]
    @State private var presentSelectQuestionSheet: EventInput.QuestionInput?
    @State private var existingQuestionID: EventInput.QuestionInput.ID?
    let previewConfiguration: PreviewConfiguration?
    
    init(
        questionsInputs: Binding<[EventInput.QuestionInput]>,
        previewConfiguration: PreviewConfiguration? = nil
    ) {
        self._questionsInputs = questionsInputs
        self.previewConfiguration = previewConfiguration
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
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(questionsInput.questionText)
                                        .foregroundColor(Color.themeText)

                                    FeedbackTypeTagView(
                                        questionsInput.feedbackType,
                                        orientation: .vertical
                                    )
                                }

                                Spacer()
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
        .overlay(
            alignment: .bottomTrailing,
            content: {
                HStack(spacing: 6) {
                    if let previewConfiguration {
                        Button {
                            previewConfiguration.presentFeedbackFlowSession(
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
                                    Text("Forhåndsvis mødegang")
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
                .padding(.bottom, 24)
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
            previewConfiguration: .init(
                title: "Preview",
                presentFeedbackFlowSession: { _ in }
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        QuestionsListView(
            questionsInputs: .constant([]),
            previewConfiguration: .init(
                title: "Preview",
                presentFeedbackFlowSession: { _ in }
            )
        )
    }
}
