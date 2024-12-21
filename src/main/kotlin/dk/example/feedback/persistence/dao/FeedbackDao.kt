package dk.example.feedback.persistence.dao

import dk.example.feedback.model.db_models.FeedbackEntity
import dk.example.feedback.persistence.table.AccountTable.default
import dk.example.feedback.persistence.table.FeedbackTable
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*

class FeedbackDao(id: EntityID<UUID>): UUIDEntity(id) {

    companion object: UUIDEntityClass<FeedbackDao>(FeedbackTable)

    var type by FeedbackTable.type
    var comment by FeedbackTable.comment
    var emoji by FeedbackTable.emoji
    var thumbsUpThumpsDown by FeedbackTable.thumbsUpThumpsDown
    var oneToTen by FeedbackTable.oneToTen
    var opinion by FeedbackTable.opinion
    var createdAt by FeedbackTable.createdAt.default(OffsetDateTime.now(ZoneOffset.UTC))
    var question by QuestionDao referencedOn FeedbackTable.question
    var manager by AccountDao referencedOn FeedbackTable.manager
    var participant by AccountDao optionalReferencedOn FeedbackTable.participant

    fun toModel(): FeedbackEntity {
        return FeedbackEntity(
            feedbackType = type,
            comment = comment,
            emoji = emoji,
            thumbsUpThumpsDown = thumbsUpThumpsDown,
            oneToTen = oneToTen,
            opinion = opinion,
            questionId = UUID.randomUUID(),
            id = id.value,
            participantId = participant?.id?.value,
        )
    }
}
