package dk.example.feedback.model.dto

import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.EventEntity
import dk.example.feedback.model.db_models.FeedbackEntity
import java.time.OffsetDateTime
import java.util.*

data class FeedbackSessionDto(
    val title: String,
    val agenda: String?,
    val questions: List<ParticipantQuestion>,
    val managerInfo: ManagerInfoDto
)

data class ManagerInfoDto(
    val name: String?,
    val email: String?,
    val phoneNumber: String?
)

data class ManagerEventDto(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val pinCode: String,
    val location : String?,
    val team: TeamDto?,
    val feedbackSummary: FeedbackSummaryDto?,
    val questions: List<ManagerQuestion>,
    val newFeedback: Int,
)

fun EventEntity.toManagerEvent(): ManagerEventDto {
    val totalFeedback = feedback.count()
    val totalEmojiFeedback = feedback.count { it.feedbackType == FeedbackType.Emoji }
    val feedbackSummary: FeedbackSummaryDto? = if (totalFeedback > 0) {
        FeedbackSummaryDto(
            totalFeedback = totalFeedback,
            verySadPercentage = totalEmojiFeedback / 100 * feedback.count { it.emoji == Emoji.VerySad }.toDouble(),
            sadPercentage = totalEmojiFeedback / 100 * feedback.count { it.emoji == Emoji.Sad }.toDouble(),
            happyPercentage = totalEmojiFeedback / 100 * feedback.count { it.emoji == Emoji.Happy }.toDouble(),
            veryHappyPercentage = totalEmojiFeedback / 100 * feedback.count { it.emoji == Emoji.VeryHappy }
                .toDouble()
        )
    } else {
        null
    }
    return ManagerEventDto(
        id = this.id,
        title = this.title,
        agenda = this.agenda,
        date = this.date,
        durationInMinutes = this.durationInMinutes,
        location = this.location,
        pinCode = this.pinCode,
        questions = this.questions.map { question ->
            val questionFeedback = feedback.filter { it.questionId == question.id }
            ManagerQuestion(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType,
                feedback = question.feedback.map { feedback ->
                    FeedbackEntity(
                        feedbackType = feedback.feedbackType,
                        comment = feedback.comment,
                        emoji = feedback.emoji,
                        thumbsUpThumpsDown = feedback.thumbsUpThumpsDown,
                        opinion = feedback.opinion,
                        oneToTen = feedback.oneToTen,
                        questionId = feedback.questionId,
                    )
                },
                feedbackSummary = if(questionFeedback.isEmpty()) {
                    null
                } else {
                    QuestionFeedbackSummary(
                        totalFeedback = questionFeedback.count(),
                        verySadCount = questionFeedback.count { it.emoji == Emoji.VerySad },
                        sadCount = questionFeedback.count { it.emoji == Emoji.Sad },
                        happyCount = questionFeedback.count { it.emoji == Emoji.Happy },
                        veryHappyCount = questionFeedback.count { it.emoji == Emoji.VeryHappy }
                    )
                }
            )
        },
        team = null,
//        team = team?.let {
//            TeamDto(
//                id = it.id,
//                teamName = it.teamName,
//                teamMembers = it.teamMembers.map {
//                    TeamMemberDto(
//                        accountId = it.account.id,
//                        name = it.account.name!!,
//                        email = it.account.email!!,
//                        phoneNumber = it.account.phoneNumber,
//                        memberStatus =  it.memberStatus,
//                    )
//                }
//            )
//        },
        feedbackSummary = feedbackSummary,
        newFeedback = this.newFeedback
    )
}

fun EventEntity.toParticipantEvent(): ParticipantEventDto {
    return ParticipantEventDto(
        id = this.id,
        title = this.title,
        agenda = this.agenda,
        date = this.date,
        durationInMinutes = this.durationInMinutes,
        location = this.location,
        pinCode = this.pinCode,
        teamName = team?.teamName,
        questions = this.questions.map { question ->
            ParticipantQuestion(
                id = question.id,
                questionText = question.questionText,
                feedbackType = question.feedbackType,
            )
        },
        feedbackProvided = feedback.isNotEmpty()
    )
}

data class ParticipantEventDto (
    var id: UUID,
    val title: String,
    val agenda: String?,
    val pinCode: String,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val teamName: String?,
    val questions: List<ParticipantQuestion>,
    val feedbackProvided: Boolean,
)

