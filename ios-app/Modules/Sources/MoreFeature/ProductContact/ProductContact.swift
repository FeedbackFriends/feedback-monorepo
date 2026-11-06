import ComposableArchitecture
import Domain
import Foundation
import Localization

@Reducer
public struct ProductContact: Sendable {
    public struct MailDraft: Equatable, Sendable, Identifiable {
        public let id: UUID
        let recipient: String
        let subject: String
        let message: String
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        let kind: ProductContactKind
        var submissionID: UUID
        var rating: Emoji?
        var message = ""
        var expectedBehavior = ""
        var contactEmail = ""
        var isSending = false
        var isCheckingMail = false
        var receipt: ProductContactReceipt?
        var error: PresentableError?
        var pendingSubmission: ProductContactInput?
        var mailDraft: MailDraft?
        @Presents var alert: AlertState<Action.Alert>?

        var cleanedMessage: String { message.trimmingCharacters(in: .whitespacesAndNewlines) }
        var cleanedEmail: String { contactEmail.trimmingCharacters(in: .whitespacesAndNewlines) }
        var isEmailValid: Bool {
            cleanedEmail.isEmpty || (cleanedEmail.utf16.count <= 254 && cleanedEmail.range(
                of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression
            ) != nil)
        }
        var isValid: Bool {
            let hasContent = kind == .bugReport ? !cleanedMessage.isEmpty : rating != nil || !cleanedMessage.isEmpty
            return hasContent && message.utf16.count <= 5000 && expectedBehavior.utf16.count <= 5000 && isEmailValid
        }
        var canEdit: Bool { !isSending && receipt == nil }

        public init(kind: ProductContactKind, submissionID: UUID) {
            self.kind = kind
            self.submissionID = submissionID
        }
    }

    public enum Field: Sendable { case message, expectedBehavior, contactEmail }
    public enum Action {
        case inputChanged(Field, String)
        case ratingTapped(Emoji)
        case sendTapped
        case submissionPrepared(ProductContactInput)
        case submissionResponse(Result<ProductContactReceipt, Error>)
        case submissionCancelled
        case mailInsteadTapped
        case mailAvailabilityReceived(Bool, String)
        case mailFinished(failed: Bool)
        case mailDismissed
        case alert(PresentationAction<Alert>)
        case closeTapped
        public enum Alert: Equatable, Sendable { case copyEmail(String) }
    }

    private enum CancelID { case submission, mailAvailability }
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .inputChanged(field, text):
                guard state.canEdit else { return .none }
                switch field {
                case .message:
                    guard state.message != text else { return .none }
                    state.message = text
                case .expectedBehavior:
                    guard state.expectedBehavior != text else { return .none }
                    state.expectedBehavior = text
                case .contactEmail:
                    guard state.contactEmail != text else { return .none }
                    state.contactEmail = text
                }
                state.pendingSubmission = nil
                state.submissionID = uuid()
                state.error = nil
                return .none

            case .ratingTapped(let rating):
                guard state.canEdit, state.rating != rating else { return .none }
                state.rating = rating
                state.pendingSubmission = nil
                state.submissionID = uuid()
                state.error = nil
                return .none

            case .sendTapped:
                guard state.isValid, state.canEdit, !state.isCheckingMail else { return .none }
                state.isSending = true
                state.error = nil
                if let pending = state.pendingSubmission { return submit(pending) }
                let draft = (
                    id: state.submissionID, kind: state.kind, rating: state.rating,
                    message: state.cleanedMessage, expected: state.expectedBehavior.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: state.cleanedEmail
                )
                return .run { send in
                    do {
                        let metadata = try await systemClient.supportMetadata()
                        await send(.submissionPrepared(ProductContactInput(
                            id: draft.id, kind: draft.kind, rating: draft.rating,
                            message: draft.message.isEmpty ? nil : draft.message,
                            expectedBehavior: draft.expected.isEmpty ? nil : draft.expected,
                            contactEmail: draft.email.isEmpty ? nil : draft.email,
                            metadata: metadata
                        )))
                    } catch {
                        guard !Task.isCancelled else { return }
                        await send(.submissionResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.submission, cancelInFlight: true)

            case .submissionPrepared(let input):
                guard state.isSending, input.id == state.submissionID else { return .none }
                state.pendingSubmission = input
                return submit(input)

            case .submissionResponse(let result):
                guard state.isSending else { return .none }
                state.isSending = false
                switch result {
                case .success(let receipt):
                    guard receipt.id == state.pendingSubmission?.id else {
                        state.error = AppFailure.supportReceiptUnavailable.localized
                        return .none
                    }
                    state.receipt = receipt
                case .failure(let error):
                    if !(error is CancellationError) && (error as? URLError)?.code != .cancelled {
                        state.error = error.localized
                    }
                }
                return .none

            case .submissionCancelled:
                state.isSending = false
                return .none

            case .mailInsteadTapped:
                guard state.canEdit, !state.isCheckingMail else { return .none }
                state.isCheckingMail = true
                return .run { send in
                    await send(.mailAvailabilityReceived(await systemClient.canComposeMail(), systemClient.supportEmail()))
                }
                .cancellable(id: CancelID.mailAvailability, cancelInFlight: true)

            case let .mailAvailabilityReceived(canCompose, address):
                guard state.isCheckingMail else { return .none }
                state.isCheckingMail = false
                guard state.canEdit else { return .none }
                if canCompose {
                    state.mailDraft = MailDraft(
                        id: state.submissionID, recipient: address,
                        subject: String(appStrings: state.kind == .productFeedback ? .moreFeedbackSubject : .moreBugSubject),
                        message: state.kind == .bugReport
                            ? String(appStrings: .productContactMailBody(state.message, state.expectedBehavior))
                            : String(appStrings: .productContactFeedbackMailBody(
                                state.rating?.localized ?? String(appStrings: .productContactNoRating), state.message
                            ))
                    )
                } else {
                    state.alert = AlertState {
                        TextState(String(appStrings: .productContactMailUnavailableTitle))
                    } actions: {
                        ButtonState(action: .copyEmail(address)) { TextState(String(appStrings: .commonCopy)) }
                        ButtonState(role: .cancel) { TextState(String(appStrings: .commonCancel)) }
                    } message: {
                        TextState(String(appStrings: .productContactMailUnavailableMessage(address)))
                    }
                }
                return .none

            case .mailFinished(let failed):
                state.mailDraft = nil
                if failed {
                    state.error = .init(
                        title: String(appStrings: .errorsGenericTitle),
                        message: String(appStrings: .productContactMailFailed)
                    )
                }
                return .none

            case .mailDismissed:
                state.mailDraft = nil
                return .none

            case .alert(.presented(.copyEmail(let address))):
                return .run { _ in await systemClient.copyText(address) }

            case .alert:
                return .none

            case .closeTapped:
                return .merge(
                    .cancel(id: CancelID.submission), .cancel(id: CancelID.mailAvailability),
                    .run { _ in await dismiss() }
                )
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func submit(_ input: ProductContactInput) -> EffectOf<Self> {
        .run { send in
            do {
                await send(.submissionResponse(.success(try await apiClient.submitProductContact(input))))
            } catch {
                guard !Task.isCancelled else { return }
                if error is CancellationError || (error as? URLError)?.code == .cancelled {
                    await send(.submissionCancelled)
                } else {
                    await send(.submissionResponse(.failure(error)))
                }
            }
        }
        .cancellable(id: CancelID.submission, cancelInFlight: true)
    }
}
