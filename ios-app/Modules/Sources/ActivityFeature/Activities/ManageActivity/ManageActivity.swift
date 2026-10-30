import ComposableArchitecture
import Domain
import Foundation
import FeedbackFlowFeature
import Utility

@Reducer
public struct ManageActivity: Sendable {
    public enum Mode: Equatable, Sendable {
        case create
        case edit
    }

    enum Step: Hashable {
        case template
        case questions
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        let mode: Mode
        var activityId: UUID?
        var originalQuestionIds: Set<UUID> = []
        var title = ""
        var selectedTemplate: FeedbackTemplate?
        var questions: [EventInput.QuestionInput] = []
        var path: [Step] = []
        var isChoosingTemplate = true
        var templateQuestions: [EventInput.QuestionInput] = []
        @Presents var previewSession: FeedbackFlowCoordinator.State?
        var createActivityRequestInFlight = false
        @Presents var alert: AlertState<Action.Alert>?

        var sendEmails = false
        var participants: [String] = []

        public static func create() -> Self {
            Self(mode: .create)
        }

        public static func edit(activity: Activity) -> Self {
            var state = Self(mode: .edit)
            state.activityId = activity.id
            state.originalQuestionIds = Set(activity.questions.map(\.id))
            state.title = activity.title
            state.questions = activity.questions.map {
                EventInput.QuestionInput(
                    id: $0.id,
                    questionText: $0.questionText,
                    feedbackType: $0.feedbackType
                )
            }
            state.selectedTemplate = FeedbackTemplate.inferred(from: state.questions)
            state.templateQuestions = state.selectedTemplate?.defaultQuestions ?? []
            state.isChoosingTemplate = false
            state.sendEmails = !activity.invitedEmails.isEmpty
            state.participants = activity.invitedEmails
            return state
        }

        var navigationTitle: String {
            switch mode {
            case .create: return "Opret aktivitet"
            case .edit: return "Rediger aktivitet"
            }
        }

        var actionButtonTitle: String {
            switch mode {
            case .create: return "Opret"
            case .edit: return "Gem"
            }
        }

        var isTitleMissing: Bool {
            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        var hasValidInput: Bool {
            !isTitleMissing && selectedTemplate != nil && !questions.isEmpty
                && questions.allSatisfy { !$0.questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        }

        var isNextDisabled: Bool {
            guard !createActivityRequestInFlight else { return true }
            switch path.last {
            case nil: return isTitleMissing
            case .template: return selectedTemplate == nil
            case .questions: return true
            }
        }

        var isSubmitDisabled: Bool {
            !hasValidInput || createActivityRequestInFlight || (mode == .create && path.last != .questions)
        }

        var hasCustomizedQuestions: Bool {
            guard questions.count == templateQuestions.count else { return true }
            return zip(questions, templateQuestions).contains {
                $0.questionText != $1.questionText || $0.feedbackType != $1.feedbackType
            }
        }

        var questionsSectionTitle: String {
            if questions.isEmpty {
                return "Byg dine spørgsmål"
            }
            return questions.count == 1 ? "1 spørgsmål klar" : "\(questions.count) spørgsmål klar"
        }

        var questionsSectionSubtitle: String {
            if selectedTemplate == .customQuestions && questions.isEmpty {
                return "Start fra bunden"
            }
            return "Åbn listen for at tilpasse spørgsmålene"
        }

        var activityInput: ActivityInput? {
            guard hasValidInput else { return nil }
            return ActivityInput(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                questions: questions,
                runMode: .automatic,
                invitedEmails: sendEmails ? participants : [],
                sendEmails: sendEmails,
                existingQuestionIds: originalQuestionIds
            )
        }

        mutating func selectTemplate(_ template: FeedbackTemplate) {
            selectedTemplate = template
            questions = template.defaultQuestions
            templateQuestions = questions
            isChoosingTemplate = false
            if mode == .edit && questions.isEmpty {
                path.append(.questions)
            }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case actionButtonTap
        case nextButtonTap
        case createResponse(Activity)
        case updateResponse(Activity)
        case presentError(Error)
        case templateSelected(FeedbackTemplate)
        case changeTemplateTapped
        case previewRequested(FeedbackFlowCoordinator.State)
        case previewSession(PresentationAction<FeedbackFlowCoordinator.Action>)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable, Sendable {
            case replaceTemplate(FeedbackTemplate)
        }
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismissAndNavigateToDetail(Activity)
        }
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .templateSelected(let template):
                guard template != state.selectedTemplate else {
                    state.isChoosingTemplate = false
                    return .none
                }
                if state.hasCustomizedQuestions {
                    state.alert = AlertState {
                        TextState("Erstat dine tilpassede spørgsmål?")
                    } actions: {
                        ButtonState(role: .destructive, action: .replaceTemplate(template)) {
                            TextState("Erstat")
                        }
                        ButtonState(role: .cancel) { TextState("Annuller") }
                    } message: {
                        TextState("Spørgsmålene erstattes med spørgsmålene fra den nye skabelon.")
                    }
                } else {
                    state.selectTemplate(template)
                }
                return .none

            case .changeTemplateTapped:
                state.isChoosingTemplate.toggle()
                return .none

            case .alert(.presented(.replaceTemplate(let template))):
                state.selectTemplate(template)
                return .none

            case .previewRequested(var preview):
                preview.isPreview = true
                state.previewSession = preview
                return .none

            case .previewSession:
                return .none

            case .nextButtonTap:
                guard state.mode == .create, !state.isNextDisabled else { return .none }
                switch state.path.last {
                case nil:
                    guard !state.isTitleMissing else { return .none }
                    state.path.append(.template)
                case .template:
                    guard state.selectedTemplate != nil else { return .none }
                    state.path.append(.questions)
                case .questions:
                    return .none
                }
                return .none

            case .actionButtonTap:
                guard !state.isSubmitDisabled else { return .none }
                guard let activityInput = state.activityInput else { return .none }
                state.createActivityRequestInFlight = true
                switch state.mode {
                case .create:
                    return .run { send in
                        do {
                            let activity = try await apiClient.createActivity(activityInput)
                            await send(.createResponse(activity))
                        } catch {
                            await send(.presentError(error))
                        }
                    }
                case .edit:
                    guard let activityId = state.activityId else { return .none }
                    return .run { send in
                        do {
                            let activity = try await apiClient.updateActivity(activityInput, activityId)
                            await send(.updateResponse(activity))
                        } catch {
                            await send(.presentError(error))
                        }
                    }
                }

            case .createResponse(let activity):
                state.createActivityRequestInFlight = false
                return .send(.delegate(.dismissAndNavigateToDetail(activity)))

            case .updateResponse:
                state.createActivityRequestInFlight = false
                return .run { _ in await dismiss() }

            case .presentError(let error):
                state.createActivityRequestInFlight = false
                state.alert = AlertState(error: error)
                return .none

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$previewSession, action: \.previewSession) { FeedbackFlowCoordinator() }
    }
}
