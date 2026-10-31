import SwiftUI
import Domain
import DesignSystem

struct QuestionsListView: View {
    
    @Binding var questionsInputs: [EventInput.QuestionInput]
    private struct QuestionDraft: Identifiable {
        let id = UUID()
        let question: EventInput.QuestionInput?
    }

    @State private var presentSelectQuestionSheet: QuestionDraft?
    @Environment(\.dismiss) private var dismiss
    
    init(
        questionsInputs: Binding<[EventInput.QuestionInput]>
    ) {
        self._questionsInputs = questionsInputs
    }
    
    var body: some View {
        Form {
            Section {
                if questionsInputs.isEmpty {
                    EmptyStateView(
                        title: "Ingen spørgsmål",
                        message: "Tilføj dit første spørgsmål nedenfor."
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }

                ForEach(questionsInputs) { questionsInput in
                    Button {
                        presentSelectQuestionSheet = QuestionDraft(question: questionsInput)
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

                Button {
                    presentSelectQuestionSheet = QuestionDraft(question: nil)
                } label: {
                    Label("Tilføj spørgsmål", systemImage: "plus")
                }
                .buttonStyle(InlineActionButtonStyle())
                .accessibilityIdentifier("questions_add_question")
            }
            .listRowBackground(Color.themeSurface)
        }
        .navigationTitle("Spørgsmål")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.themeBackground.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .supportingTextStyle()
        .foregroundColor(Color.themeTextSecondary)
        .sheet(
            item: $presentSelectQuestionSheet,
            content: { draft in
                QuestionPickerView(
                    existingQuestionID: draft.question?.id,
                    feedbackTypeSelected: draft.question?.feedbackType,
                    questionTextField: draft.question?.questionText ?? ""
                ) { selectedQuestionInput in
                    if let index = self.questionsInputs.firstIndex(where: { $0.id == selectedQuestionInput.id }) {
                        self.questionsInputs[index] = selectedQuestionInput
                    } else {
                        self.questionsInputs.append(selectedQuestionInput)
                    }
                }
            }
        )
        .safeAreaInset(edge: .bottom) {
            Button("Gem") { dismiss() }
                .buttonStyle(LargeButtonStyle())
                .accessibilityIdentifier("questions_save")
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
                .background(Color.themeBackground)
        }
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
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        QuestionsListView(
            questionsInputs: .constant([])
        )
    }
}
