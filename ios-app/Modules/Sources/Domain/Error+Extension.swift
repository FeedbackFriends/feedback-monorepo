import Foundation
import Logger

public extension Error {
    
    var localized: PresentableError {
        var title: String = "Error 💩"
        var message: String = "An unexpected issue occurred. Try again."
        if let apiError = self as? ApiError, let domainError = apiError.domainCode {
            switch domainError {
            case .feedbackAlreadySubmitted:
                title = "Duplicate feedback"
                message = "Feedback already submitted for this event."
            case .eventAlreadyJoined:
                title = "Already joined"
                message = "You already joined this event."
            case .pincodeNotFound:
                title = "Invalid PIN code"
                message = "The provided pin code does not match any active event."
            case .cannotJoinOwnEvent:
                title = "Not allowed"
                message = "You cannot join your own event."
            case .cannotGiveFeedbackToSelf:
                title = "Not allowed"
                message = "You cannot give feedback to yourself."
            }
        }
        if let urlError = self as? URLError {
            message = urlError.localizedDescription
        }
        
        let nsError = self as NSError
        if let localizedMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
            message = localizedMessage
        }
        Logger.debug("Error of type: \(type(of: self))/nlocalizedDescription: \(self.localizedDescription)")
        return PresentableError(title: title, message: message)
    }
}
