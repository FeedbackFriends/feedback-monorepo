import SwiftUI
import Domain
import DesignSystem
import FeedbackFlowFeature
import ComposableArchitecture

public struct QuestionsListView: View {
    
    public struct PreviewConfiguration {
        let title: String
        let agenda: String?
        let presentFeedbackFlowSession: (FeedbackFlowCoordinator.State) -> Void
        
        public init(
            title: String,
            agenda: String? = nil,
            presentFeedbackFlowSession: @escaping (FeedbackFlowCoordinator.State) -> Void
        ) {
            self.title = title
            self.agenda = agenda
            self.presentFeedbackFlowSession = presentFeedbackFlowSession
        }
    }
    
    let recentlyUsedQuestions: Set<RecentlyUsedQuestions>
    @Binding var questionsInputs: [EventInput.QuestionInput]
    @State private var presentSelectQuestionSheet: EventInput.QuestionInput?
    @State private var existingQuestionID: EventInput.QuestionInput.ID?
    let previewConfiguration: PreviewConfiguration?
    
    public init(
        recentlyUsedQuestions: Set<RecentlyUsedQuestions>,
        questionsInputs: Binding<[EventInput.QuestionInput]>,
        previewConfiguration: PreviewConfiguration? = nil
    ) {
        self.recentlyUsedQuestions = recentlyUsedQuestions
        self._questionsInputs = questionsInputs
        self.previewConfiguration = previewConfiguration
    }
    
    public var body: some View {
        Group {
            if questionsInputs.isEmpty {
                EmptyStateView(
                    title: "No questions",
                    message: "Tap '+' to add a question"
                ).frame(maxHeight: .infinity)
            } else {
                Form {
                    ForEach(questionsInputs) { questionsInput in
                        Button {
                            self.existingQuestionID = questionsInput.id
                            self.presentSelectQuestionSheet = questionsInput
                        } label: {
                            HStack(spacing: 12) {
                                questionsInput.feedbackType.image
                                    .font(.title)
                                    .foregroundStyle(Color.themeText)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(questionsInput.questionText)
                                        .foregroundColor(Color.themeText)
                                    Text(questionsInput.feedbackType.title)
                                        .font(.montserratRegular, 10)
                                        .foregroundColor(Color.themeTextSecondary)
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
        .navigationTitle("Questions")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.themeBackground.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .font(.montserratRegular, 13)
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
                .presentationDetents(.init([.height(354)]))
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
                                        title: previewConfiguration.title,
                                        agenda: previewConfiguration.agenda,
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
                                    Text("Preview session")
                                }
                                Text("How participants will experience your session.")
                                    .font(.montserratRegular, 8)
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
            recentlyUsedQuestions: .init(),
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
            recentlyUsedQuestions: .init(),
            questionsInputs: .constant([]),
            previewConfiguration: .init(
                title: "Preview",
                presentFeedbackFlowSession: { _ in }
            )
        )
    }
}
