import Foundation
import OpenAPIRuntime
import Domain
import OpenAPIURLSession
import ComposableArchitecture
import Utility

public extension Feedback {
    init(_ feedback: Components.Schemas.FeedbackEntity) {
        switch feedback.feedbackType {
        case .emoji:
            self = .init(
                type: .emoji(
                    emoji: .init(rawValue: feedback.emoji!.rawValue.lowercasingFirst())!,
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
            )
        case .comment:
            self = .init(
                type: .comment(comment: feedback.comment!),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
            )
        case .thumpsUpThumpsDown:
            self = .init(
                type: FeedbackTypeWithData.thumpsUpThumpsDown(
                    thumbsUpThumpsDown: .init(rawValue: feedback.thumbsUpThumpsDown!.rawValue.lowercasingFirst())!,
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
            )
        case .zeroToTen:
            self = .init(
                type: FeedbackTypeWithData.zeroToTen(
                    zeroToTen: Int(feedback.zeroToTen!),
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
            )
        case .opinion:
            self = .init(
                type: FeedbackTypeWithData.opinion(
                    opinion: .init(rawValue: feedback.opinion!.rawValue.lowercasingFirst())!,
                    comment: feedback.comment
                ),
                questionId: UUID(uuidString: feedback.questionId)!,
                seenByManager: feedback.seenByManager,
                createdAt: feedback.createdAt
            )
        }
    }
}

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
    init(_ event: Components.Schemas.ManagerEventDto) {
        let overallFeedbackSummary: OverallFeedbackSummary? = if let eventSummary = event.overallFeedbackSummary {
            OverallFeedbackSummary(
                segmentationStats: .init(
                    verySadPercentage: eventSummary.segmentationStats.verySadPercentage,
                    sadPercentage: eventSummary.segmentationStats.sadPercentage,
                    happyPercentage: eventSummary.segmentationStats.happyPercentage,
                    veryHappyPercentage: eventSummary.segmentationStats.veryHappyPercentage
                ),
                countStats: .init(
                    verySadCount: Int(eventSummary.countStats.verySadCount),
                    sadCount: Int(eventSummary.countStats.sadCount),
                    happyCount: Int(eventSummary.countStats.happyCount),
                    veryHappyCount: Int(eventSummary.countStats.veryHappyCount),
                    commentsCount: Int(eventSummary.countStats.commentsCount)
                ),
                unseenResponses: Int(eventSummary.unseenResponses),
                responses: Int(eventSummary.responses)
            )
        } else {
            nil
        }
        self.init(
            id: UUID(uuidString: event.id)!,
            title: event.title,
            agenda: event.agenda,
            date: event.date,
            pinCode: event.pinCode.flatMap { PinCode(value: $0)
            },
            durationInMinutes: Int(event.durationInMinutes),
            location: event.location,
            ownerInfo: .init(
                name: event.ownerInfo.name,
                email: event.ownerInfo.email,
                phoneNumber: event.ownerInfo.phoneNumber
            ),
            overallFeedbackSummary: overallFeedbackSummary,
            questions: event.questions.map {
                let questionFeedbackSummary: QuestionFeedbackSummary? = if let questionSummary = $0.questionFeedbackSummary {
                    if let emojiSummary = questionSummary.emojiQuestionFeedbackSummary {
                        QuestionFeedbackSummary(
                            emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary(
                                countVerySad: Int(emojiSummary.countVerySad),
                                countSad: Int(emojiSummary.countSad),
                                countHappy: Int(emojiSummary.countHappy),
                                countVeryHappy: Int(emojiSummary.countVerySad),
                                percentageVerySad: emojiSummary.percentageVerySad,
                                percentageSad: emojiSummary.percentageSad,
                                percentageHappy: emojiSummary.percentageHappy,
                                percentageVeryHappy: emojiSummary.percentageVeryHappy
                            )
                        )
                    } else if let thumpsSummary = questionSummary.thumpsQuestionFeedbackSummary {
                        QuestionFeedbackSummary(
                            thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary(
                                countUp: Int(thumpsSummary.countUp),
                                countDown: Int(thumpsSummary.countDown),
                                percentageUp: thumpsSummary.percentageUp,
                                percentageDown: thumpsSummary.percentageDown
                            )
                        )
                    } else if let opinionSummary = questionSummary.opinionQuestionFeedbackSummary {
                        QuestionFeedbackSummary(
                            opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary(
                                countStronglyAgree: Int(opinionSummary.countStronglyAgree),
                                countAgree: Int(opinionSummary.countAgree),
                                countStronglyDisagree: Int(opinionSummary.countStronglyDisagree),
                                countDisagree: Int(opinionSummary.countDisagree),
                                percentageStronglyAgree: opinionSummary.percentageStronglyAgree,
                                percentageAgree: opinionSummary.percentageAgree,
                                percentageStronglyDisagree: opinionSummary.percentageStronglyDisagree,
                                percentageDisagree: opinionSummary.percentageDisagree
                            )
                        )
                    } else if let zeroToTenSummary = questionSummary.zeroToTenQuestionFeedbackSummary {
                        QuestionFeedbackSummary(
                            zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary(
                                percentageValue0: zeroToTenSummary.percentageValue0,
                                percentageValue1: zeroToTenSummary.percentageValue1,
                                percentageValue2: zeroToTenSummary.percentageValue2,
                                percentageValue3: zeroToTenSummary.percentageValue3,
                                percentageValue4: zeroToTenSummary.percentageValue4,
                                percentageValue5: zeroToTenSummary.percentageValue5,
                                percentageValue6: zeroToTenSummary.percentageValue6,
                                percentageValue7: zeroToTenSummary.percentageValue7,
                                percentageValue8: zeroToTenSummary.percentageValue8,
                                percentageValue9: zeroToTenSummary.percentageValue9,
                                percentageValue10: zeroToTenSummary.percentageValue10,
                                countValue0: Int(zeroToTenSummary.countValue0),
                                countValue1: Int(zeroToTenSummary.countValue1),
                                countValue2: Int(zeroToTenSummary.countValue2),
                                countValue3: Int(zeroToTenSummary.countValue3),
                                countValue4: Int(zeroToTenSummary.countValue4),
                                countValue5: Int(zeroToTenSummary.countValue5),
                                countValue6: Int(zeroToTenSummary.countValue6),
                                countValue7: Int(zeroToTenSummary.countValue7),
                                countValue8: Int(zeroToTenSummary.countValue8),
                                countValue9: Int(zeroToTenSummary.countValue9),
                                countValue10: Int(zeroToTenSummary.countValue10)
                            )
                        )
                    } else {
                        fatalError("Feedback type not implemented")
                    }
                } else {
                    nil
                }
                return ManagerQuestion(
                    id: UUID(uuidString: $0.id)!,
                    questionText: $0.questionText,
                    feedbackType: .init($0.feedbackType.rawValue),
                    feedback: $0.feedback.map { Feedback($0) },
                    feedbackSummary: questionFeedbackSummary
                )
            },
            isDraft: event.isDraft,
            invitedEmails: event.invitedEmails,
            participants: event.participants.map {
                .init(name: $0.name, email: $0.email, phoneNumber: $0.phoneNumber)
            },
            calendarProvider: event.calendarProvider.map { .init($0.rawValue) }
        )
    }
}

public extension EventWrapper {
    init(_ event: Components.Schemas.EventWrapperDto) {
        self.init(
            event: .init(event.event),
            recentlyUsedQuestions:
                Set(
                    event.recentlyUsedQuestions.map {
                        .init(
                            questionText: $0.questionText,
                            feedbackType: .init($0.feedbackType.rawValue),
                            updatedAt: $0.updatedAt
                        )
                    }
                )
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
                name: event.ownerInfo.email,
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
//            invitedEmails: event.invitedEmails,
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
    init(_ session: Components.Schemas.SessionDto) {
        let accountInfo: AccountInfo = AccountInfo(
            name: session.accountInfo.name,
            email: session.accountInfo.email,
            phoneNumber: session.accountInfo.phoneNumber
        )
        let role: Role? = switch session.role {
        case .some("Participant"):
                .participant
        case .some("Manager"):
                .manager
        default:
            nil
        }
        
        let managerData: ManagerData? = session.managerData.flatMap {
            ManagerData(
                managerEvents: .init(uniqueElements: $0.managerEvents.map { .init($0) }),
                activity: .init($0.activity),
                recentlyUsedQuestions: .init($0.recentlyUsedQuestions.map {
                    .init(
                        questionText: $0.questionText,
                        feedbackType: .init($0.feedbackType.rawValue),
                        updatedAt: $0.updatedAt
                    )
                }),
                feedbackSessionHash: .init(uuidString: $0.feedbackSessionHash)!
            )
        }
        
        self.init(
            participantEvents: .init(
                uniqueElements: session.participantEvents.map {
                    guard let id = UUID(uuidString: $0.id) else {
                        fatalError("Could not parse UUID for participant event: \($0.id)")
                    }
                    return ParticipantEvent(
                        id: id,
                        title: $0.title,
                        agenda: $0.agenda,
                        date: $0.date,
                        pinCode: $0.pinCode.map { PinCode(value: $0) },
                        location: $0.location,
                        durationInMinutes: Int($0.durationInMinutes),
                        questions: $0.questions.map {
                            guard let id = UUID(uuidString: $0.id) else {
                                fatalError("Could not parse UUID for participant question: \($0.id)")
                            }
                            return ParticipantQuestion(
                                id: id,
                                questionText: $0.questionText,
                                feedbackType: FeedbackType($0.feedbackType.rawValue)
                            )
                        },
                        feedbackSubmitted: $0.feedbackSubmited,
                        ownerInfo: OwnerInfo(
                            name: $0.ownerInfo.name,
                            email: $0.ownerInfo.email,
                            phoneNumber: $0.ownerInfo.phoneNumber
                        ),
                        recentlyJoined: $0.recentlyJoined
                    )
                }
            ),
            managerData: managerData,
            accountInfo: accountInfo,
            role: role
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

