import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct EditQuestionsView: View {
    @Bindable var store: StoreOf<EditQuestions>
    @State private var presentSelectQuestionSheet: EventInput.QuestionInput?
    @State private var existingQuestionIndex: Int?

    public init(store: StoreOf<EditQuestions>) {
        self.store = store
    }

    public var body: some View {
        let questionsInputs = $store.questionsInputs
        List {
            Section {
                if questionsInputs.wrappedValue.isEmpty {
                    EmptyStateView(
                        title: "No questions added yet",
                        message: "Tap + to add the first feedback question for this session."
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(Array(questionsInputs.wrappedValue.enumerated()), id: \.offset) { index, question in
                        Button {
                            existingQuestionIndex = index
                            presentSelectQuestionSheet = question
                        } label: {
                            HStack(spacing: 12) {
                                question.feedbackType.image
                                    .font(.title)
                                    .foregroundStyle(Color.themeText)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(question.questionText)
                                        .foregroundColor(Color.themeText)
                                    Text(question.feedbackType.title)
                                        .font(.montserratRegular, 10)
                                        .foregroundColor(Color.themeTextSecondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .onDelete { indexSet in
                        questionsInputs.wrappedValue.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        questionsInputs.wrappedValue.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            } header: {
                headerLabel("Feedback questions")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .navigationTitle("Feedback draft")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButtonView { store.send(.closeButtonTap) }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    existingQuestionIndex = nil
                    presentSelectQuestionSheet = .init(questionText: "", feedbackType: .emoji)
                } label: {
                    Image.plus
                }
            }
        }
        .sheet(
            item: $presentSelectQuestionSheet,
            content: { questionInput in
                QuestionPickerView(
                    existingQuestionIndex: existingQuestionIndex,
                    feedbackTypeSelected: questionInput.feedbackType,
                    questionTextField: questionInput.questionText
                ) { selectedQuestionInput, index in
                    if let index {
                        questionsInputs.wrappedValue[index] = selectedQuestionInput
                    } else {
                        questionsInputs.wrappedValue.append(selectedQuestionInput)
                    }
                }
                .presentationDetents(.init([.height(354)]))
            }
        )
        .safeAreaInset(edge: .bottom) {
            Button("Save draft") {
                store.send(.saveButtonTap)
            }
            .buttonStyle(LargeButtonStyle())
            .isLoading(store.saveRequestInFlight)
            .disabled(store.saveButtonDisabled)
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, 12)
            .background(Color.themeBackground.ignoresSafeArea(edges: .bottom))
        }
        .successOverlay(
            message: "Questions saved",
            show: $store.showSuccessOverlay
        )
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

private extension EditQuestionsView {
    func headerLabel(_ title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
        }
        .sectionHeaderStyle()
        .padding(.leading, 8)
    }
}

#Preview {
    NavigationStack {
        EditQuestionsView(
            store: StoreOf<EditQuestions>.init(
                initialState: .init(
                    event: .mock(),
                    recentlyUsedQuestions: .init()
                ),
                reducer: {
                    EditQuestions()
                }
            )
        )
    }
}
