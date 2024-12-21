package dk.example.feedback.persistence.repo

import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.FeedbackEntity
import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.dto.ManagerInfoDto
import dk.example.feedback.persistence.dao.*
import dk.example.feedback.persistence.table.*
import dk.example.feedback.persistence.table.EventParticipantTable.event
import org.jetbrains.exposed.dao.id.EntityID
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Transactional
@Component
class FeedbackRepo {

    fun getEventFeedback(eventId: UUID): List<FeedbackEntity> {
        return QuestionDao
            .find { QuestionTable.event eq eventId }
            .flatMap { it.feedback }
            .map { it.toModel() }
    }

    fun getTotalFeedbackSubmissionsForAccount(accountId: String): Long {
        return FeedbackDao.find { FeedbackTable.participant eq accountId }.count()
    }

    fun persistFeedback(feedbackList: List<FeedbackEntity>, managerId: String, participantId: String, eventId: UUID) {

        val manager = AccountDao.findById(EntityID(managerId, AccountTable))
            ?: throw IllegalArgumentException("Manager not found with id: $managerId")

        feedbackList.forEach { feedbackEntity ->
            feedbackEntity.validateFeedbackInput()
            FeedbackDao.new {
                this.type = feedbackEntity.feedbackType
                this.comment = feedbackEntity.comment
                this.emoji = feedbackEntity.emoji
                this.thumbsUpThumpsDown = feedbackEntity.thumbsUpThumpsDown
                this.opinion = feedbackEntity.opinion
                this.oneToTen = feedbackEntity.oneToTen
                this.question = QuestionDao.findById(feedbackEntity.questionId)
                    ?: throw IllegalArgumentException("Question not found with id: ${feedbackEntity.questionId}")
                this.manager = manager
                this.participant = AccountDao.findById(EntityID(participantId, AccountTable))
            }
        }
    }

    private fun FeedbackEntity.validateFeedbackInput() {
        when (feedbackType) {
            FeedbackType.Emoji -> {
                requireNotNull(emoji) { "Emoji is required for feedback type Emoji" }
                check(thumbsUpThumpsDown == null) { "ThumbsUp/ThumpsDown is not required for feedback type Emoji" }
                check(oneToTen == null) { "OneToTen is not required for feedback type Emoji" }
                check(opinion == null) { "Opinion is not required for feedback type Emoji" }
            }

            FeedbackType.Comment -> {
                requireNotNull(comment) { "Comment is required for feedback type Comment" }
                check(emoji == null) { "Emoji is not required for feedback type Comment" }
                check(thumbsUpThumpsDown == null) { "ThumbsUp/ThumpsDown is not required for feedback type Comment" }
                check(oneToTen == null) { "OneToTen is not required for feedback type Comment" }
                check(opinion == null) { "Opinion is not required for feedback type Comment" }
            }

            FeedbackType.ThumpsUpThumpsDown -> {
                requireNotNull(thumbsUpThumpsDown) { "ThumbsUp/ThumpsDown is required for feedback type ThumpsUpThumpsDown" }
                check(emoji == null) { "Emoji is not required for feedback type ThumpsUpThumpsDown" }
                check(oneToTen == null) { "OneToTen is not required for feedback type ThumpsUpThumpsDown" }
                check(opinion == null) { "Opinion is not required for feedback type ThumpsUpThumpsDown" }
            }

            FeedbackType.Opinion -> {
                requireNotNull(opinion) { "Opinion is required for feedback type Opinion" }
                check(emoji == null) { "Emoji is not required for feedback type Opinion" }
                check(thumbsUpThumpsDown == null) { "ThumbsUp/ThumpsDown is not required for feedback type Opinion" }
                check(oneToTen == null) { "OneToTen is not required for feedback type Opinion" }
            }

            FeedbackType.OneToTen -> {
                require(oneToTen in 1..10) { "OneToTen must be between 1 and 10 for feedback type OneToTen" }
                check(emoji == null) { "Emoji is not required for feedback type OneToTen" }
                check(thumbsUpThumpsDown == null) { "ThumbsUp/ThumpsDown is not required for feedback type OneToTen" }
                check(opinion == null) { "Opinion is not required for feedback type OneToTen" }
            }
        }
    }
}
