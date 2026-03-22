import Foundation
import Domain
import OpenAPI
import Utility

public extension Components.Schemas.FeedbackInput {
    init(_ feedback: FeedbackInput) {
        switch feedback.type {
        case .emoji(emoji: let emoji, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                emoji: .init(input: emoji),
                questionId: feedback.questionId.uuidString,
                feedbackType: .emoji
            )
        case .comment(comment: let comment):
            self.init(
                comment: comment,
                questionId: feedback.questionId.uuidString,
                feedbackType: .comment
            )
        case .thumpsUpThumpsDown(thumbsUpThumpsDown: let thumbsUpThumpsDown, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                thumbsUpThumpsDown: .init(input: thumbsUpThumpsDown),
                questionId: feedback.questionId.uuidString,
                feedbackType: .thumpsUpThumpsDown
            )
        case .opinion(opinion: let opinion, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                opinion: .init(input: opinion),
                questionId: feedback.questionId.uuidString,
                feedbackType: .opinion
            )
        case .zeroToTen(zeroToTen: let zeroToTen, comment: let optionalComment):
            self.init(
                comment: optionalComment,
                zeroToTen: Int32(zeroToTen),
                questionId: feedback.questionId.uuidString,
                feedbackType: .zeroToTen
            )
        }
    }
}

public extension Components.Schemas.FeedbackInput.ThumbsUpThumpsDownPayload {
    init(input: ThumbsUpThumpsDown) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput.EmojiPayload {
    init(input: Emoji) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension Components.Schemas.FeedbackInput.OpinionPayload {
    init(input: Opinion) {
        self.init(rawValue: input.rawValue.uppercasingFirst())!
    }
}

public extension ManagerEvent {
    init(_ feedbackFlow: Components.Schemas.FeedbackFlowDto) {
        self.init(
            id: UUID(uuidString: feedbackFlow.id) ?? UUID(),
            title: feedbackFlow.title,
            agenda: feedbackFlow.insights.summary,
            date: feedbackFlow.analytics.lastSessionAt ?? .distantPast,
            pinCode: nil,
            durationInMinutes: 0,
            location: nil,
            ownerInfo: .init(
                name: feedbackFlow.owner.name,
                email: feedbackFlow.owner.email,
                phoneNumber: nil
            ),
            overallFeedbackSummary: nil,
            questions: feedbackFlow.currentQuestions.map {
                ManagerQuestion(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.text,
                    feedbackType: .comment,
                    feedback: [],
                    feedbackSummary: nil
                )
            },
            isDraft: false,
            invitedEmails: [],
            participants: [],
            calendarProvider: nil
        )
    }
}

public extension EventWrapper {
    init(_ feedbackFlow: Components.Schemas.FeedbackFlowDto) {
        self.init(
            event: .init(feedbackFlow),
            recentlyUsedQuestions: []
        )
    }
}

public extension ParticipantEvent {
    init(_ event: Components.Schemas.ParticipantEventDto) {
        self.init(
            id: UUID(uuidString: event.id)!,
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            pinCode: event.pinCode.map { PinCode(value: $0) },
            location: event.location,
            durationInMinutes: Int(event.durationInMinutes),
            questions: event.questions.map {
                .init(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: FeedbackType($0.feedbackType.rawValue)
                )
            },
            feedbackSubmitted: event.feedbackSubmited,
            ownerInfo: .init(
                name: event.ownerInfo.name,
                email: event.ownerInfo.email,
                phoneNumber: event.ownerInfo.phoneNumber
            ),
            recentlyJoined: event.recentlyJoined
        )
    }
}

public extension Components.Schemas.EventInput {
    init(_ event: EventInput) {
        self.init(
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            durationInMinutes: Int32(event.durationInMinutes),
            location: event.location,
            invitedEmails: [],
            questions: event.questions.map {
                guard let feedbackType: Components.Schemas.QuestionInput.FeedbackTypePayload = .init(rawValue: $0.feedbackType.rawValue.uppercasingFirst()) else {
                    fatalError("Could not create FeedbackTypePayload for \($0.feedbackType.rawValue.uppercasingFirst())")
                }
                return .init(questionText: $0.questionText, feedbackType: feedbackType)
            }
        )
    }
}

public extension FeedbackSession {
    init(_ feedbackSession: Components.Schemas.FeedbackSessionDto, pinCode: PinCode) {
        self.init(
            title: feedbackSession.title,
            agenda: feedbackSession.agenda,
            questions: feedbackSession.questions.map {
                ParticipantQuestion(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: .init($0.feedbackType.rawValue)
                )
            },
            ownerInfo: .init(
                name: feedbackSession.ownerInfo.name,
                email: feedbackSession.ownerInfo.email,
                phoneNumber: feedbackSession.ownerInfo.phoneNumber
            ),
            pinCode: pinCode,
            date: feedbackSession.date
        )
    }
}

public extension ApiError {
    init(apiErrorDto: Components.Schemas.ApiError) {
        self.init(
            timestamp: apiErrorDto.timestamp,
            message: apiErrorDto.message,
            domainCode: apiErrorDto.domainCode.flatMap { .init(domainCodeDto: $0) },
            exceptionType: apiErrorDto.exceptionType,
            path: apiErrorDto.path
        )
    }
}

public extension DomainCode {
    init(domainCodeDto: Components.Schemas.ApiError.DomainCodePayload) {
        switch domainCodeDto {
        case .feedbackAlreadySubmitted:
            self = .feedbackAlreadySubmitted
        case .eventAlreadyJoined:
            self = .eventAlreadyJoined
        case .cannotJoinOwnEvent:
            self = .cannotJoinOwnEvent
        case .cannotGiveFeedbackToSelf:
            self = .cannotGiveFeedbackToSelf
        case .pincodeNotFound:
            self = .pincodeNotFound
        }
    }
}

public extension Session {
    init(_ bootstrap: Components.Schemas.BootstrapDto) {
        let accountInfo = AccountInfo(
            name: bootstrap.accountInfo.name,
            email: bootstrap.accountInfo.email,
            phoneNumber: bootstrap.accountInfo.phoneNumber
        )
        let role: Role? = switch bootstrap.role {
        case .some("Participant"):
            .participant
        case .some("Manager"):
            .manager
        default:
            nil
        }

        self.init(
            participantEvents: [],
            managerData: bootstrap.managerData.map(ManagerData.init),
            accountInfo: accountInfo,
            role: role
        )
    }
}

public extension Session {
    init(_ session: Components.Schemas.SessionDto) {
        self.init(
            participantEvents: [],
            accountInfo: .init(name: nil, email: nil, phoneNumber: nil),
            role: nil
        )
    }
}

public extension ManagerData {
    init(_ dto: Components.Schemas.ManagerDataDto) {
        self.init(
            managerEvents: .init(uniqueElements: dto.feedbackFlows.map(ManagerEvent.init)),
            activity: .init(dto.activity),
            recentlyUsedQuestions: [],
            feedbackSessionHash: UUID(uuidString: dto.sessionHash) ?? UUID()
        )
    }
}

public extension Activity {
    init(_ activity: Components.Schemas.ActivityDto) {
        self.init(
            items: activity.items.map {
                .init(
                    id: UUID(uuidString: $0.id)!,
                    date: $0.date,
                    eventTitle: $0.eventTitle,
                    eventId: UUID(uuidString: $0.eventId)!,
                    newFeedbackCount: Int($0.newFeedbackCount),
                    seenByManager: $0.seenByManager
                )
            },
            unseenTotal: Int(activity.unseenTotal)
        )
    }
}
