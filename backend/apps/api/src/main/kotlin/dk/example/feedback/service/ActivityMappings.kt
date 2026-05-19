package dk.example.feedback.service

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ActivityIndicatorDto
import dk.example.feedback.dto.ActivityTrendDirectionDto
import dk.example.feedback.dto.ActivityTrendDto
import dk.example.feedback.dto.ActivityTrendMetricDto
import dk.example.feedback.dto.OwnerDto
import dk.example.feedback.dto.ParticipantQuestionDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.dto.ParticipantSummaryDto
import dk.example.feedback.dto.QuestionDto
import dk.example.feedback.dto.QuestionFeedbackSummaryDto
import dk.example.feedback.dto.EventDetailDto
import dk.example.feedback.dto.EventDto
import dk.example.feedback.dto.EventQuestionDto
import dk.example.feedback.dto.EmojiQuestionFeedbackSummary
import dk.example.feedback.dto.OpinionQuestionFeedbackSummary
import dk.example.feedback.dto.OverallFeedbackCountStatsDto
import dk.example.feedback.dto.OverallFeedbackSegmentationStatsDto
import dk.example.feedback.dto.OverallFeedbackSummaryDto
import dk.example.feedback.dto.ThumpsQuestionFeedbackSummary
import dk.example.feedback.dto.ZeroToTenQuestionFeedbackSummary
import dk.example.feedback.helpers.participantResponses
import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.database.ActivityEntity
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown

fun ActivityEntity.toActivityDto(
    events: List<EventEntity>,
    pinCodeProvider: (java.util.UUID) -> String?,
): ActivityDto {
    val sortedEvents = events.sortedByDescending { it.date }
    return ActivityDto(
        id = id,
        title = title,
        agenda = agenda,
        owner = OwnerDto(
            id = manager.id,
            name = manager.name,
            email = manager.email,
        ),
        runMode = runMode,
        sendEmails = sendEmails,
        invitedEmails = invites.map { it.email },
        events = sortedEvents
            .map { it.toActivityEventDto(pinCodeProvider(it.id)) },
        currentQuestions = questions
            .sortedBy { it.index }
            .map { QuestionDto(id = it.id, text = it.questionText, feedbackType = it.feedbackType) },
        trend = sortedEvents.toActivityTrendDto(),
    )
}

fun EventEntity.toActivityEventDto(pinCode: String?): EventDto {
    return EventDto(
        id = id,
        date = date,
        durationInMinutes = durationInMinutes,
        location = location,
        pinCode = pinCode,
        createdFromMailListener = createdFromMailListener,
        calendarProvider = calendarProvider,
        calendarEventId = calendarEventId,
        averageRating = averageZeroToTenRating(),
        overallFeedbackSummary = generateOverallFeedbackSummary(
            participantResponses = feedback.participantResponses(),
            feedback = feedback,
        ),
        questionsSnapshot = questions
            .sortedBy { it.index }
            .map { QuestionDto(id = it.id, text = it.questionText, feedbackType = it.feedbackType) },
    )
}

private fun EventEntity.averageZeroToTenRating(): Double? {
    return questions
        .flatMap { it.feedback }
        .mapNotNull { it.zeroToTen?.toDouble() }
        .average()
        .takeUnless { it.isNaN() }
}

private fun List<EventEntity>.toActivityTrendDto(): ActivityTrendDto {
    val comparableScores = mapNotNull { event ->
        event.averageZeroToTenRating()?.div(2.0)
    }
    val latestValue = comparableScores.getOrNull(0)
    val previousValue = comparableScores.getOrNull(1)
    val deltaValue = if (latestValue != null && previousValue != null) latestValue - previousValue else null
    val direction = when {
        latestValue == null || previousValue == null -> ActivityTrendDirectionDto.insufficient_data
        deltaValue != null && deltaValue >= 0.5 -> ActivityTrendDirectionDto.improving
        deltaValue != null && deltaValue <= -0.5 -> ActivityTrendDirectionDto.declining
        else -> ActivityTrendDirectionDto.stable
    }
    val indicator = when (direction) {
        ActivityTrendDirectionDto.improving -> ActivityIndicatorDto.positive
        ActivityTrendDirectionDto.declining -> ActivityIndicatorDto.negative
        ActivityTrendDirectionDto.stable -> ActivityIndicatorDto.neutral
        ActivityTrendDirectionDto.insufficient_data -> ActivityIndicatorDto.neutral
    }
    return ActivityTrendDto(
        direction = direction,
        indicator = indicator,
        metric = ActivityTrendMetricDto.average_rating,
        latestValue = latestValue,
        previousValue = previousValue,
        delta = deltaValue,
        comparedEventCount = minOf(2, comparableScores.size),
    )
}

fun EventEntity.toParticipantEventDto(
    pinCode: String?,
    feedbackSubmitted: Boolean,
    recentlyJoined: Boolean,
): ParticipantEventDto {
    return ParticipantEventDto(
        id = id,
        date = date,
        pinCode = pinCode,
        durationInMinutes = durationInMinutes,
        location = location,
        createdFromMailListener = createdFromMailListener,
        ownerInfo = dk.example.feedback.dto.OwnerInfoDto(
            name = manager.name,
            email = manager.email,
            phoneNumber = manager.phoneNumber,
        ),
        questions = questions
            .sortedBy { it.index }
            .map {
                ParticipantQuestionDto(
                    id = it.id,
                    questionText = it.questionText,
                    feedbackType = it.feedbackType,
                )
            },
        feedbackSubmited = feedbackSubmitted,
        recentlyJoined = recentlyJoined,
    )
}

fun EventEntity.toEventDetailDto(
    pinCode: String?,
    participants: List<AccountEntity>,
): EventDetailDto {
    return EventDetailDto(
        id = id,
        date = date,
        pinCode = pinCode,
        durationInMinutes = durationInMinutes,
        location = location,
        calendarProvider = calendarProvider,
        owner = OwnerDto(
            id = manager.id,
            name = manager.name,
            email = manager.email,
        ),
        overallFeedbackSummary = generateOverallFeedbackSummary(
            participantResponses = feedback.participantResponses(),
            feedback = feedback,
        ),
        participants = participants.map {
            ParticipantSummaryDto(
                name = it.name,
                email = it.email,
                phoneNumber = it.phoneNumber,
            )
        },
        questions = questions
            .sortedBy { it.index }
            .map { question ->
                EventQuestionDto(
                    id = question.id,
                    text = question.questionText,
                    feedbackType = question.feedbackType,
                    feedback = question.feedback,
                    summary = generateQuestionFeedbackSummary(question.feedback, question.feedbackType),
                )
            },
    )
}

private fun generateOverallFeedbackSummary(
    participantResponses: Int,
    feedback: List<FeedbackEntity>,
): OverallFeedbackSummaryDto? {
    val totalEmojiFeedback = feedback.count { it.feedbackType == FeedbackType.Emoji }
    val emojiFeedback = feedback.filter { it.feedbackType == FeedbackType.Emoji }
    return if (participantResponses > 0) {
        OverallFeedbackSummaryDto(
            segmentationStats = OverallFeedbackSegmentationStatsDto(
                verySadPercentage = calculateEmojiPercentage(feedback, Emoji.VerySad, totalEmojiFeedback),
                sadPercentage = calculateEmojiPercentage(feedback, Emoji.Sad, totalEmojiFeedback),
                happyPercentage = calculateEmojiPercentage(feedback, Emoji.Happy, totalEmojiFeedback),
                veryHappyPercentage = calculateEmojiPercentage(feedback, Emoji.VeryHappy, totalEmojiFeedback),
            ),
            countStats = OverallFeedbackCountStatsDto(
                verySadCount = emojiFeedback.count { it.emoji == Emoji.VerySad },
                sadCount = emojiFeedback.count { it.emoji == Emoji.Sad },
                happyCount = emojiFeedback.count { it.emoji == Emoji.Happy },
                veryHappyCount = emojiFeedback.count { it.emoji == Emoji.VeryHappy },
                commentsCount = feedback.count { it.comment != null },
            ),
            unseenResponses = feedback.filter { !it.seenByManager }.participantResponses(),
            responses = participantResponses,
        )
    } else {
        null
    }
}

fun generateQuestionFeedbackSummary(
    feedback: List<FeedbackEntity>,
    type: FeedbackType,
): QuestionFeedbackSummaryDto? {
    val totalFeedback = feedback.count()
    if (totalFeedback == 0) {
        return null
    }
    return when (type) {
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

        FeedbackType.Comment -> null

        FeedbackType.ThumpsUpThumpsDown -> {
            QuestionFeedbackSummaryDto(
                thumpsQuestionFeedbackSummary = ThumpsQuestionFeedbackSummary(
                    countUp = feedback.count { it.thumbsUpThumpsDown == ThumbsUpThumpsDown.Up },
                    countDown = feedback.count { it.thumbsUpThumpsDown == ThumbsUpThumpsDown.Down },
                    percentageUp = calculateThumbsPercentage(feedback, ThumbsUpThumpsDown.Up, totalFeedback),
                    percentageDown = calculateThumbsPercentage(feedback, ThumbsUpThumpsDown.Down, totalFeedback),
                ),
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
                ),
            )
        }
    }
}

private fun calculateEmojiPercentage(feedback: List<FeedbackEntity>, emoji: Emoji, totalFeedback: Int): Double {
    if (totalFeedback == 0) return 0.0
    return (feedback.count { it.emoji == emoji } * 100.0) / totalFeedback
}

private fun calculateThumbsPercentage(feedback: List<FeedbackEntity>, thumb: ThumbsUpThumpsDown, totalFeedback: Int): Double {
    if (totalFeedback == 0) return 0.0
    return (feedback.count { it.thumbsUpThumpsDown == thumb } * 100.0) / totalFeedback
}

private fun calculateOpinionPercentage(feedback: List<FeedbackEntity>, opinion: Opinion, totalFeedback: Int): Double {
    if (totalFeedback == 0) return 0.0
    return (feedback.count { it.opinion == opinion } * 100.0) / totalFeedback
}

private fun calculateZeroToTenPercentage(feedback: List<FeedbackEntity>, zeroToTen: Int, totalFeedback: Int): Double {
    if (totalFeedback == 0) return 0.0
    return (feedback.count { it.zeroToTen == zeroToTen } * 100.0) / totalFeedback
}
