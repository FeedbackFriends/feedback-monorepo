package dk.example.feedback.persistence.repo

import dk.example.feedback.controller.FeedbackAlreadyGivenException
import dk.example.feedback.model.*
import dk.example.feedback.model.db_models.FeedbackEntity
import dk.example.feedback.persistence.dao.*
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.dao.id.EntityID
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID

@Transactional
@Component
class FeedbackRepo {

    fun throwExceptionIfAccountAlreadyGivenFeedback(eventId: UUID, accountId: String)  {
        QuestionDao.find { QuestionTable.event eq eventId }.flatMap { it.feedback }.forEach {
            if (it.participant?.id?.value == accountId) {
                return
            }
        }
        throw FeedbackAlreadyGivenException()
    }

    fun getFeedbackCountByAccountId(accountId: String): Long {
        return FeedbackDao.find { FeedbackTable.participant eq accountId }.count()
    }

    fun sendFeedback(feedback: List<FeedbackEntity>, managerId: String, participantId: String, eventId: UUID) {

        feedback.forEach {

            val feedback: FeedbackEntity = when (it.feedbackType) {
                FeedbackType.Emoji -> {
                    val emoji: Emoji = it.emoji ?: throw IllegalArgumentException("Emoji is required since type is emoji")
                    FeedbackEntity(emoji = emoji, comment = it.comment, feedbackType = FeedbackType.Emoji, questionId = it.questionId)
                }
                FeedbackType.Comment -> {
                    val comment: String = it.comment ?: throw IllegalArgumentException("Comment is required since type is comment")
                    FeedbackEntity(comment = comment, feedbackType = FeedbackType.Comment, questionId = it.questionId)
                }
                FeedbackType.ThumpsUpThumpsDown -> {
                    val thumbsUpThumpsDown: ThumbsUpThumpsDown = it.thumbsUpThumpsDown ?: throw IllegalArgumentException("ThumpsUp is required since type is thumpsUpThumpsDown")
                    FeedbackEntity(thumbsUpThumpsDown = thumbsUpThumpsDown, comment = it.comment, feedbackType = FeedbackType.ThumpsUpThumpsDown, questionId = it.questionId)
                }
                FeedbackType.Opinion -> {
                    val opinion: Opinion = it.opinion ?: throw IllegalArgumentException("Opinion is required since type is opinion")
                    FeedbackEntity(opinion = opinion, comment = it.comment, feedbackType = FeedbackType.Opinion, questionId = it.questionId)
                }
                FeedbackType.OneToTen -> {
                    val oneToTen: Int = it.oneToTen ?: throw IllegalArgumentException("OneToTen is required since type is oneToTen")
                    // check if oneToTen is between 1 and 10
                    if (oneToTen < 1 || oneToTen > 10) {
                        throw IllegalArgumentException("OneToTen must be between 1 and 10")
                    }
                    FeedbackEntity(oneToTen = oneToTen, comment = it.comment, feedbackType = FeedbackType.OneToTen, questionId = it.questionId)
                }
            }

            FeedbackDao.new {
                this.createdAt = OffsetDateTime.now(ZoneOffset.UTC)
                this.type = feedback.feedbackType
                this.comment = feedback.comment
                this.emoji = feedback.emoji
                this.thumbsUpThumpsDown = feedback.thumbsUpThumpsDown
                this.opinion = feedback.opinion
                this.oneToTen = feedback.oneToTen
                this.createdAt = OffsetDateTime.now(ZoneOffset.UTC)
                this.question = QuestionDao.findById(feedback.questionId) ?: throw IllegalArgumentException("Question not found")
                this.manager = AccountDao.findById(EntityID(managerId, AccountTable)) ?: throw IllegalArgumentException("Manager not found")
                this.participant = AccountDao.findById(EntityID(participantId, AccountTable))
            }

            EventDao.findById(eventId)?.apply {
                this.newFeedback += 1
            }
        }
    }
}