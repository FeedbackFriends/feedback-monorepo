package dk.example.feedback.service

import dk.example.feedback.dto.EventWrapperDto
import dk.example.feedback.dto.EmojiQuestionFeedbackSummary
import dk.example.feedback.dto.OverallFeedbackSummaryDto
import dk.example.feedback.dto.ManagerEventDto
import dk.example.feedback.dto.ManagerQuestion
import dk.example.feedback.dto.OpinionQuestionFeedbackSummary
import dk.example.feedback.dto.OverallFeedbackCountStatsDto
import dk.example.feedback.dto.OverallFeedbackSegmentationStatsDto
import dk.example.feedback.dto.OwnerInfoDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.dto.ParticipantQuestionDto
import dk.example.feedback.dto.QuestionFeedbackSummaryDto
import dk.example.feedback.dto.SessionDto
import dk.example.feedback.dto.ThumpsQuestionFeedbackSummary
import dk.example.feedback.dto.ZeroToTenQuestionFeedbackSummary
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.participantResponses
import dk.example.feedback.helpers.verifyAccountHasId
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.model.exceptions.EventAlreadyJoinedException
import dk.example.feedback.model.exceptions.FeedbackAlreadySubmittedException
import dk.example.feedback.payloads.EventInput
import dk.example.feedback.persistence.pincodegenerator.PinCodeGenerator
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import java.util.*
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class EventService(
    private val eventRepo: EventRepo,
    private val activityRepo: ActivityRepo,
) {

    fun createEvent(eventInput: EventInput, jwt: Jwt): EventWrapperDto {
        val generatedPinCode = PinCodeGenerator(eventRepo = eventRepo).generate()
        val managerId = jwt.getAccountId()
        val eventEntity = eventRepo.persistEvent(
            title = eventInput.title,
            agenda = eventInput.agenda,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            generatedPinCode = generatedPinCode,
            questions = eventInput.questions.map { question ->
                Pair(question.questionText, question.feedbackType)
            },
            managerId = managerId
        )
        return EventWrapperDto(
            event = eventEntity.toManagerEvent(
            pinCode = generatedPinCode
            ),
            recentlyUsedQuestions = getRecentlyUsedQuestions(accountId = jwt.getAccountId())
        )
    }

    fun deleteEvent(eventId: UUID, jwt: Jwt) {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        eventRepo.deleteEvent(eventId)
    }

    fun updateEvent(eventInput: EventInput, eventId: UUID, jwt: Jwt): EventWrapperDto {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        if (event.feedback.isNotEmpty()) {
            throw IllegalArgumentException("Cannot update event with feedback")
        }
        val updatedEvent = eventRepo.updateEvent(
            eventId = eventId,
            title = eventInput.title,
            agenda = eventInput.agenda,
            date = eventInput.date,
            location = eventInput.location,
            durationInMinutes = eventInput.durationInMinutes,
            questions = eventInput.questions.map { question ->
                Pair(question.questionText, question.feedbackType)
            }
        )
        return EventWrapperDto(
            event = updatedEvent.toManagerEvent(
                pinCode = getPinCodeForEvent(eventId)
            ),
            recentlyUsedQuestions = getRecentlyUsedQuestions(accountId = jwt.getAccountId())
        )
    }

    fun getManagerEvents(managerId: String): List<ManagerEventDto> {
        return eventRepo.getManagerEvents(managerId).map {
            it.toManagerEvent(pinCode = getPinCodeForEvent(eventId = it.id))
        }
    }

    fun getParticipantEvents(accountId: String): List<ParticipantEventDto> {
        val eventsWrapped = eventRepo.getParticipantEvents(accountId)
        return eventsWrapped.map { wrapped ->
            val accountDidSubmitFeedbackForEvent =
                eventRepo.accountDidSubmitFeedbackForEvent(wrapped.event.id, accountId)
            wrapped.event.toParticipantEvent(
                getPinCodeForEvent(eventId = wrapped.event.id),
                feedbackSubmitted = accountDidSubmitFeedbackForEvent,
                recentlyJoined = wrapped.recentlyJoined
            )
        }
    }

    fun getRecentlyUsedQuestions(accountId: String): List<SessionDto.RecentlyUsedQuestions> {
        return eventRepo.getRecentlyUsedQuestions(accountId).map {
            SessionDto.RecentlyUsedQuestions(
                questionText = it.questionText,
                feedbackType = it.feedbackType,
                updatedAt = it.updatedAt,
            )
        }
    }

    fun joinEvent(pinCode: String, jwt: Jwt): ParticipantEventDto {
        val accountId = jwt.getAccountId()
        val event = eventRepo.getEventByPinCode(pinCode)
        throwIfAccountIsManager(event, accountId)
        throwIfAccountAlreadyJoinedEvent(event, accountId)
        throwIfFeedbackAlreadySubmitted(event, accountId)
        eventRepo.updateOrCreateParticipant(eventId = event.id, accountId = accountId, feedbackSubmitted = false)
        return event.toParticipantEvent(
            pinCode = getPinCodeForEvent(event.id),
            feedbackSubmitted = false,
            recentlyJoined = true
        )
    }

    fun markEventAsSeen(eventId: UUID, jwt: Jwt) {
        val event = eventRepo.getEvent(eventId)
        jwt.verifyAccountHasId(event.manager.id)
        eventRepo.markEventAsSeen(eventId)
        activityRepo.markAsSeen(accountId = jwt.getAccountId(), eventId = eventId)
    }

    private fun getPinCodeForEvent(eventId: UUID): String? {
        return eventRepo.getPinCodeForEvent(eventId)
    }

    private fun throwIfAccountIsManager(event: EventEntity, accountId: String) {
        val isManager = event.manager.id == accountId
        if (isManager) {
            throw IllegalArgumentException("Owner of event cannot give feedback")
        }
    }

    private fun throwIfFeedbackAlreadySubmitted(event: EventEntity, accountId: String) {
        val events = eventRepo.getParticipantEvents(accountId)
        val feedbackAlreadySubmitted = events.find { it.event.id == event.id }
        if (feedbackAlreadySubmitted != null) {
            throw FeedbackAlreadySubmittedException(eventId = event.id, accountId = accountId)
        }
    }

    private fun throwIfAccountAlreadyJoinedEvent(event: EventEntity, accountId: String) {
        val participantEvents = eventRepo.getParticipantEvents(accountId)
        val hasJoinedEvent = participantEvents.any { it.event.id == event.id }
        if (hasJoinedEvent) {
            throw EventAlreadyJoinedException(eventId = event.id, accountId = accountId)
        }
    }
}

fun EventEntity.toManagerEvent(pinCode: String?): ManagerEventDto {
    val isDraft = questions.isEmpty()
    return ManagerEventDto(
        id = id,
        title = title,
        agenda = agenda,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        isDraft = isDraft,
        pinCode = pinCode,
        invitedEmails = invites.sortedBy { it.createdAt }.map { it.email },
        questions = questions.sortedBy { it.createdAt }.map { question ->
            ManagerQuestion(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType,
                questionFeedbackSummary = generateQuestionFeedbackSummary(
                    feedback = question.feedback,
                    type = question.feedbackType,
                ),
                feedback = question.feedback,
            )
        },
        overallFeedbackSummary = generateOverallFeedbackSummary(
            participantResponses = feedback.participantResponses(),
            feedback = feedback
        ),
        ownerInfo = OwnerInfoDto(name = manager.name, email = manager.email, phoneNumber = manager.phoneNumber)
    )
}

fun EventEntity.toParticipantEvent(
    pinCode: String?,
    feedbackSubmitted: Boolean,
    recentlyJoined: Boolean
): ParticipantEventDto {
    return ParticipantEventDto(
        id = id,
        title = title,
        agenda = agenda,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        createdFromMailListener = createdFromMailListener,
        pinCode = pinCode,
        questions = questions.map { question ->
            ParticipantQuestionDto(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType
            )
        },
        feedbackSubmited = feedbackSubmitted,
        ownerInfo = OwnerInfoDto(name = manager.name, email = manager.email, phoneNumber = manager.phoneNumber),
        recentlyJoined = recentlyJoined
    )
}

private fun generateOverallFeedbackSummary(
    participantResponses: Int,
    feedback: List<FeedbackEntity>
): OverallFeedbackSummaryDto? {
    val totalEmojiFeedback = feedback.count { it.feedbackType == FeedbackType.Emoji }
    val emojiFeedback = feedback.filter { it.feedbackType == FeedbackType.Emoji }
    return if (participantResponses > 0) {
        OverallFeedbackSummaryDto(
            segmentationStats = OverallFeedbackSegmentationStatsDto(
                verySadPercentage = calculateEmojiPercentage(feedback, Emoji.VerySad, totalEmojiFeedback),
                sadPercentage = calculateEmojiPercentage(feedback, Emoji.Sad, totalEmojiFeedback),
                happyPercentage = calculateEmojiPercentage(feedback, Emoji.Happy, totalEmojiFeedback),
                veryHappyPercentage = calculateEmojiPercentage(feedback, Emoji.VeryHappy, totalEmojiFeedback)
            ),
            countStats = OverallFeedbackCountStatsDto(
                verySadCount = emojiFeedback.count { it.emoji == Emoji.VerySad },
                sadCount = emojiFeedback.count { it.emoji == Emoji.Sad },
                happyCount = emojiFeedback.count { it.emoji == Emoji.Happy },
                veryHappyCount = emojiFeedback.count { it.emoji == Emoji.VeryHappy },
                commentsCount = feedback.count { it.comment != null }
            ),
            unseenResponses = feedback.filter { !it.seenByManager }.participantResponses(),
            responses = participantResponses,
        )
    } else null
}

private fun generateQuestionFeedbackSummary(
    feedback: List<FeedbackEntity>,
    type: FeedbackType
): QuestionFeedbackSummaryDto? {
    val totalFeedback = feedback.count()
    if (totalFeedback == 0) {
        return null
    }
    return when(type) {
        FeedbackType.Emoji -> {
            QuestionFeedbackSummaryDto(
                emojiQuestionFeedbackSummary = EmojiQuestionFeedbackSummary(
                        countVerySad = feedback.count { it.emoji == Emoji.VerySad },
                        countSad = feedback.count { it.emoji == Emoji.Sad },
                        countHappy = feedback.count { it.emoji == Emoji.Happy },
                        countVeryHappy = feedback.count { it.emoji == Emoji.VeryHappy },
                        percentageVerySad = calculateEmojiPercentage(feedback, Emoji.VerySad, totalFeedback),
                        percentageSad = calculateEmojiPercentage(feedback, Emoji.Sad, totalFeedback),
                        percentageHappy = calculateEmojiPercentage(feedback, Emoji.Happy, totalFeedback),
                        percentageVeryHappy = calculateEmojiPercentage(feedback, Emoji.VeryHappy, totalFeedback),
                ),
            )
        }
        FeedbackType.Comment -> {
            null
        }
        FeedbackType.ThumpsUpThumpsDown -> {
            QuestionFeedbackSummaryDto(
                thumpsQuestionFeedbackSummary = ThumpsQuestionFeedbackSummary(
                    countUp = feedback.count { it.thumbsUpThumpsDown == ThumbsUpThumpsDown.Up },
                    countDown = feedback.count { it.thumbsUpThumpsDown == ThumbsUpThumpsDown.Down },
                    percentageUp = calculateThumpsPercentage(feedback, ThumbsUpThumpsDown.Up, totalFeedback),
                    percentageDown = calculateThumpsPercentage(feedback, ThumbsUpThumpsDown.Down, totalFeedback),
                )
            )
        }
        FeedbackType.Opinion -> {
            QuestionFeedbackSummaryDto(
                opinionQuestionFeedbackSummary = OpinionQuestionFeedbackSummary(
                    countStronglyAgree = feedback.count { it.opinion == Opinion.StronglyAgree },
                    countAgree = feedback.count { it.opinion == Opinion.Agree },
                    countStronglyDisagree = feedback.count { it.opinion == Opinion.StronglyDisagree },
                    countDisagree = feedback.count { it.opinion == Opinion.Disagree },
                    percentageStronglyAgree = calculateOpinionPercentage(feedback, Opinion.StronglyAgree, totalFeedback),
                    percentageAgree = calculateOpinionPercentage(feedback, Opinion.Agree, totalFeedback),
                    percentageStronglyDisagree = calculateOpinionPercentage(feedback, Opinion.StronglyDisagree, totalFeedback),
                    percentageDisagree = calculateOpinionPercentage(feedback, Opinion.Disagree, totalFeedback),
                ),
            )
        }
        FeedbackType.ZeroToTen -> {
            QuestionFeedbackSummaryDto(
                zeroToTenQuestionFeedbackSummary = ZeroToTenQuestionFeedbackSummary(
                        countValue0 = feedback.count { it.zeroToTen == 0 },
                        countValue1 = feedback.count { it.zeroToTen == 1 },
                        countValue2 = feedback.count { it.zeroToTen == 2 },
                        countValue3 = feedback.count { it.zeroToTen == 3 },
                        countValue4 = feedback.count { it.zeroToTen == 4 },
                        countValue5 = feedback.count { it.zeroToTen == 5 },
                        countValue6 = feedback.count { it.zeroToTen == 6 },
                        countValue7 = feedback.count { it.zeroToTen == 7 },
                        countValue8 = feedback.count { it.zeroToTen == 8 },
                        countValue9 = feedback.count { it.zeroToTen == 9 },
                        countValue10 = feedback.count { it.zeroToTen == 10 },
                        percentageValue0 = calculateZeroToTenPercentage(feedback, 0, totalFeedback),
                        percentageValue1 = calculateZeroToTenPercentage(feedback, 1, totalFeedback),
                        percentageValue2 = calculateZeroToTenPercentage(feedback, 2, totalFeedback),
                        percentageValue3 = calculateZeroToTenPercentage(feedback, 3, totalFeedback),
                        percentageValue4 = calculateZeroToTenPercentage(feedback, 4, totalFeedback),
                        percentageValue5 = calculateZeroToTenPercentage(feedback, 5, totalFeedback),
                        percentageValue6 = calculateZeroToTenPercentage(feedback, 6, totalFeedback),
                        percentageValue7 = calculateZeroToTenPercentage(feedback, 7, totalFeedback),
                        percentageValue8 = calculateZeroToTenPercentage(feedback, 8, totalFeedback),
                        percentageValue9 = calculateZeroToTenPercentage(feedback, 9, totalFeedback),
                        percentageValue10 = calculateZeroToTenPercentage(feedback, 10, totalFeedback),
                )
            )
        }
    }
}

private fun calculateEmojiPercentage(
    feedback: List<FeedbackEntity>,
    emoji: Emoji,
    totalEmojiFeedback: Int
): Double {
    if (totalEmojiFeedback == 0) return 0.0
    return (feedback.count { it.emoji == emoji } * 100.0) / totalEmojiFeedback
}

private fun calculateThumpsPercentage(
    feedback: List<FeedbackEntity>,
    thump: ThumbsUpThumpsDown,
    totalEmojiFeedback: Int
): Double {
    if (totalEmojiFeedback == 0) return 0.0
    return (feedback.count { it.thumbsUpThumpsDown == thump } * 100.0) / totalEmojiFeedback
}

private fun calculateOpinionPercentage(
    feedback: List<FeedbackEntity>,
    opinion: Opinion,
    totalEmojiFeedback: Int
): Double {
    if (totalEmojiFeedback == 0) return 0.0
    return (feedback.count { it.opinion == opinion } * 100.0) / totalEmojiFeedback
}

private fun calculateZeroToTenPercentage(
    feedback: List<FeedbackEntity>,
    zeroToTen: Int,
    totalEmojiFeedback: Int
): Double {
    if (totalEmojiFeedback == 0) return 0.0
    return (feedback.count { it.zeroToTen == zeroToTen } * 100.0) / totalEmojiFeedback
}
