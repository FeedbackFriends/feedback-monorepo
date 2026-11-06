import Foundation
import Localization
import Logger

public extension Error {
    var localized: PresentableError {
        Logger.debug("Error of type: \(type(of: self)); localizedDescription: \(localizedDescription)")
        if let apiError = self as? ApiError {
            if let title = apiError.userTitle?.trimmingCharacters(in: .whitespacesAndNewlines),
               let message = apiError.userMessage?.trimmingCharacters(in: .whitespacesAndNewlines),
               !title.isEmpty, !message.isEmpty {
                return .init(title: title, message: message)
            }
            if let code = apiError.domainCode {
                return code.presentation
            }
            if let statusCode = apiError.statusCode {
                return AppFailure.http(statusCode: statusCode).presentation
            }
        }
        if let failure = self as? AppFailure { return failure.presentation }
        if let failure = self as? any AppFailureProviding { return failure.appFailure.presentation }
        if let error = self as? URLError {
            switch error.code {
            case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff:
                return .init(title: String(appStrings: .errorsOfflineTitle), message: String(appStrings: .errorsOfflineMessage))
            case .timedOut:
                return .init(title: String(appStrings: .errorsTimeoutTitle), message: String(appStrings: .errorsTimeoutMessage))
            case .userAuthenticationRequired:
                return .init(title: String(appStrings: .errorsSignInTitle), message: String(appStrings: .errorsSignInMessage))
            case .cannotFindHost, .cannotConnectToHost, .networkConnectionLost, .dnsLookupFailed,
                 .secureConnectionFailed, .serverCertificateUntrusted:
                return .init(title: String(appStrings: .errorsGenericTitle), message: String(appStrings: .errorsConnectionMessage))
            default:
                break
            }
        }
        if let error = self as? AuthenticationError {
            switch error {
            case .notSignedIn:
                return .init(title: String(appStrings: .errorsSignInTitle), message: String(appStrings: .errorsSignInMessage))
            case .loginCancelled:
                return .init(title: String(appStrings: .errorsAuthenticationTitle), message: String(appStrings: .errorsLoginCancelledMessage))
            default:
                return .init(title: String(appStrings: .errorsAuthenticationTitle), message: String(appStrings: .errorsAuthenticationMessage))
            }
        }
        return .init(title: String(appStrings: .errorsGenericTitle), message: String(appStrings: .errorsGenericMessage))
    }
}

private extension DomainCode {
    var presentation: PresentableError {
        switch self {
        case .feedbackAlreadySubmitted:
            return .init(title: String(appStrings: .errorsDuplicateFeedbackTitle), message: String(appStrings: .errorsDuplicateFeedbackMessage))
        case .eventAlreadyJoined:
            return .init(title: String(appStrings: .errorsAlreadyJoinedTitle), message: String(appStrings: .errorsAlreadyJoinedMessage))
        case .pincodeNotFound:
            return .init(title: String(appStrings: .errorsInvalidPinTitle), message: String(appStrings: .errorsInvalidPinMessage))
        case .cannotJoinOwnEvent:
            return .init(title: String(appStrings: .errorsNotAllowedTitle), message: String(appStrings: .errorsOwnSessionMessage))
        case .cannotGiveFeedbackToSelf:
            return .init(title: String(appStrings: .errorsNotAllowedTitle), message: String(appStrings: .errorsSelfFeedbackMessage))
        case .forbiddenResourceAccess:
            return .init(title: String(appStrings: .errorsNotAllowedTitle), message: String(appStrings: .errorsForbiddenMessage))
        }
    }
}

private extension AppFailure {
    var presentation: PresentableError {
        var title = String(appStrings: .errorsGenericTitle)
        let message: String
        switch self {
        case .http(let statusCode):
            switch statusCode {
            case 401:
                title = String(appStrings: .errorsSignInTitle)
                message = String(appStrings: .errorsSignInMessage)
            case 403:
                title = String(appStrings: .errorsNotAllowedTitle)
                message = String(appStrings: .errorsForbiddenMessage)
            case 404: message = String(appStrings: .errorsNotFoundMessage)
            case 408: message = String(appStrings: .errorsTimeoutMessage)
            case 409: message = String(appStrings: .errorsConflictMessage)
            case 429: message = String(appStrings: .errorsRateLimitedMessage)
            case 500...599: message = String(appStrings: .errorsServerMessage)
            default: message = String(appStrings: .errorsGenericMessage)
            }
        case .cacheUpdate: message = String(appStrings: .errorsCacheUpdateMessage)
        case .inviteUnavailable: message = String(appStrings: .errorsInviteUnavailableMessage)
        case .sessionUnavailable: message = String(appStrings: .errorsSessionUnavailableMessage)
        case .authenticationFailed:
            title = String(appStrings: .errorsAuthenticationTitle)
            message = String(appStrings: .errorsAuthenticationMessage)
        case .rateLimited: message = String(appStrings: .errorsRateLimitedMessage)
        }
        return .init(title: title, message: message)
    }
}
