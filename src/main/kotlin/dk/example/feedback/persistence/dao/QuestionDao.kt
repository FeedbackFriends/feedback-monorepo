package dk.example.feedback.persistence.dao

import dk.example.feedback.model.db_models.QuestionEntity
import dk.example.feedback.persistence.table.AccountTable.default
import dk.example.feedback.persistence.table.FeedbackTable
import dk.example.feedback.persistence.table.QuestionTable
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*

class QuestionDao(id: EntityID<UUID>): UUIDEntity(id) {

    companion object: UUIDEntityClass<QuestionDao>(QuestionTable)

    var questionText by QuestionTable.questionText
    var feedbackType by QuestionTable.feedbackType
    var createdAt by QuestionTable.createdAt.default(OffsetDateTime.now(ZoneOffset.UTC))
    var updatedAt by QuestionTable.updatedAt.default(OffsetDateTime.now(ZoneOffset.UTC))
    var event by EventDao referencedOn QuestionTable.event
    var index by QuestionTable.index
    val feedback by FeedbackDao referrersOn FeedbackTable.question
    var manager by AccountDao referencedOn QuestionTable.manager

    fun toModel(): QuestionEntity {
        return QuestionEntity(
            id = id.value,
            questionText = questionText,
            feedbackType = feedbackType,
            createdAt = createdAt,
            updatedAt = updatedAt,
            index = index,
            feedback = feedback.map { it.toModel() },
            managerId = manager.id.value
        )
    }
}
