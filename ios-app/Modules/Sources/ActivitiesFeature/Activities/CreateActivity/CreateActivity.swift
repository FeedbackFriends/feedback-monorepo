import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct CreateActivity: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        var title = ""
        var description = ""
        var selectedTemplate: FeedbackTemplate?
        var questions: [EventInput.QuestionInput] = []
        var showQuestionsList = false
        var selectedRunMode: RunMode = .manual
        var previewSession: FocusPreviewSession?
        var createActivityRequestInFlight = false
        @Presents var alert: AlertState<Never>?

        var showInfoSheet = false
        var didCopyEmail = false
        let botEmail = "feedback@letsgrow.dk"

        var sendEmails = false
        var participants: [String] = []
        var newEmail = ""

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
            let agenda = {
                let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? nil : trimmed
            }()
            let runMode: ActivityInput.RunMode = switch selectedRunMode {
            case .manual: .manual
            case .automatic: .automatic
            }
            return ActivityInput(
                title: title,
                agenda: agenda,
                questions: questions,
                runMode: runMode,
                invitedEmails: sendEmails ? participants : [],
                sendEmails: sendEmails
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
        case createButtonTapped
        case createResponse
        case presentError(Error)
        case templateSelected(FeedbackTemplate)
        case clearTemplateTapped
        case copyBotEmailTapped
        case alert(PresentationAction<Never>)
    }

    public init() {}

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented

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

            case .createButtonTapped:
                guard let activityInput = state.activityInput else { return .none }
                state.createActivityRequestInFlight = true
                return .run { send in
                    do {
                        _ = try await apiClient.createActivity(activityInput)
                        await send(.createResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }

            case .createResponse:
                state.createActivityRequestInFlight = false
                guard isPresented else { return .none }
                return .run { _ in
                    await dismiss()
                }

            case .presentError(let error):
                state.createActivityRequestInFlight = false
                state.alert = AlertState {
                    TextState("Could not create activity")
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
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
