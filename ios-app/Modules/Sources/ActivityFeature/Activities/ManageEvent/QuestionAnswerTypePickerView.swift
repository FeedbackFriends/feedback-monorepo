import DesignSystem
import Domain
import FeedbackFlowFeature
import Localization
import SwiftUI

struct QuestionAnswerTypePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: FeedbackType?
    private let questionText: String
    private let onChoose: (FeedbackType) -> Void

    init(selectedType: FeedbackType?, questionText: String, onChoose: @escaping (FeedbackType) -> Void) {
        self._selectedType = State(initialValue: selectedType)
        self.questionText = questionText
        self.onChoose = onChoose
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 12) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            SelectionOptionRowView(
                                title: type.title,
                                subtitle: type.shortDescription,
                                icon: type.image,
                                isSelected: type == selectedType,
                                accessibilityIdentifier: "question_editor_type_\(type.rawValue)"
                            ) { selectedType = type }
                            .accessibilityHint(type.helpDescription)
                        }
                    }
                    if let selectedType {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(String(appStrings: .questionsPreviewTitle))
                            FeedbackQuestionIllustrationView(
                                questionText: questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? String(appStrings: .questionsPreviewPlaceholder) : questionText,
                                feedbackType: selectedType
                            )
                            .id(selectedType)
                        }
                    }
                }
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle(String(appStrings: .questionsAnswerType))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(appStrings: .commonChoose)) {
                        guard let selectedType else { return }
                        onChoose(selectedType)
                        dismiss()
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(selectedType == nil)
                    .accessibilityIdentifier("question_type_confirm_button")
                }
            }
            .sensoryFeedback(.selection, trigger: selectedType)
        }
    }
}
