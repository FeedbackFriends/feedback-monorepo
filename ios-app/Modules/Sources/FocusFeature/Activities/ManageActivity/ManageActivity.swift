import ComposableArchitecture
import Domain
import Foundation
import Utility

@Reducer
public struct ManageActivity: Sendable {
    public enum Mode: Equatable, Sendable {
        case create
        case edit
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        let mode: Mode
        var activityId: UUID?
        var originalQuestionIds: Set<UUID> = []
        var title = ""
        var description = ""
        var selectedTemplate: FeedbackTemplate?
        var questions: [EventInput.QuestionInput] = []
        var showQuestionsList = false
        var previewSession: FocusPreviewSession?
        var createActivityRequestInFlight = false
        @Presents var alert: AlertState<Never>?

        var sendEmails = false
        var participants: [String] = []
        var newEmail = ""

        public static func create() -> Self {
            var state = Self(mode: .create)
            state.selectTemplate(.standardMeeting)
            return state
        }

        public static func edit(activity: Activity) -> Self {
            var state = Self(mode: .edit)
            state.activityId = activity.id
            state.originalQuestionIds = Set(activity.questions.map(\.id))
            state.title = activity.title
            state.description = activity.agenda ?? ""
            state.questions = activity.questions.map {
                EventInput.QuestionInput(
                    id: $0.id,
                    questionText: $0.questionText,
                    feedbackType: $0.feedbackType
                )
            }
            state.selectedTemplate = FeedbackTemplate.inferred(from: state.questions)
            state.sendEmails = !activity.invitedEmails.isEmpty
            state.participants = activity.invitedEmails
            return state
        }

        var navigationTitle: String {
            switch mode {
            case .create: return "Tilføj aktivitet"
            case .edit: return "Rediger aktivitet"
            }
        }

        var actionButtonTitle: String {
            switch mode {
            case .create: return "Opret"
            case .edit: return "Gem"
            }
        }

        var isCreateDisabled: Bool {
            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedTemplate == nil || questions.isEmpty || createActivityRequestInFlight
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
            return "Åbn listen for at tilpasse forløbet"
        }

        var activityInput: ActivityInput? {
            guard selectedTemplate != nil else { return nil }
            return ActivityInput(
                title: title,
                agenda: description.nilIfBlank,
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
            if questions.isEmpty {
                showQuestionsList = true
            }
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case actionButtonTap
        case createResponse(Activity)
        case updateResponse(Activity)
        case presentError(Error)
        case templateSelected(FeedbackTemplate)
        case clearTemplateTapped
        case alert(PresentationAction<Never>)
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
                state.selectTemplate(template)
                return .none

            case .clearTemplateTapped:
                state.selectedTemplate = nil
                state.questions = []
                return .none

            case .actionButtonTap:
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
    }
}
