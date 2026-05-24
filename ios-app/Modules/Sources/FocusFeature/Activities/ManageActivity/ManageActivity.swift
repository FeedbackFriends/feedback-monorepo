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

        var showInfoSheet = false
        var didCopyEmail = false
        let botEmail = "feedback@letsgrow.dk"

        var sendEmails = false
        var participants: [String] = []
        var newEmail = ""

        public init() {
            self.mode = .create
        }

        public init(activity: Activity) {
            self.mode = .edit
            self.activityId = activity.id
            self.originalQuestionIds = Set(activity.questions.map(\.id))
            self.title = activity.title
            self.description = activity.agenda ?? ""
            self.questions = activity.questions.map {
                EventInput.QuestionInput(
                    id: $0.id,
                    questionText: $0.questionText,
                    feedbackType: $0.feedbackType
                )
            }
            self.selectedTemplate = FeedbackTemplate.inferred(from: self.questions)
            self.sendEmails = !activity.invitedEmails.isEmpty
            self.participants = activity.invitedEmails
        }

        var navigationTitle: String {
            switch mode {
            case .create: return "Create focus"
            case .edit: return "Edit focus"
            }
        }

        var actionButtonTitle: String {
            switch mode {
            case .create: return "Create"
            case .edit: return "Save"
            }
        }

        var isCreateDisabled: Bool {
            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedTemplate == nil || questions.isEmpty || createActivityRequestInFlight
        }

        var questionsSectionTitle: String {
            if questions.isEmpty {
                return "Build your questions"
            }
            return "\(questions.count) question\(questions.count == 1 ? "" : "s") ready"
        }

        var questionsSectionSubtitle: String {
            if selectedTemplate == .buildYourOwn && questions.isEmpty {
                return "Start from scratch"
            }
            return "Open the list to customize the flow"
        }

        var activityInput: ActivityInput? {
            guard selectedTemplate != nil else { return nil }
            return ActivityInput(
                title: title,
                agenda: description.nilIfBlank,
                questions: questions,
                runMode: .manual,
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
        case copyBotEmailTapped
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

            case .copyBotEmailTapped:
                state.didCopyEmail = true
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
                let title: String
                switch state.mode {
                case .create: title = "Could not create activity"
                case .edit: title = "Could not save activity"
                }
                state.alert = AlertState {
                    TextState(title)
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
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
