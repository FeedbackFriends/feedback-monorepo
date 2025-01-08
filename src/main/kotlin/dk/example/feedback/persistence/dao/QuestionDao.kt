package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.QuestionEntity
import dk.example.feedback.persistence.table.FeedbackTable
import dk.example.feedback.persistence.table.QuestionTable
import org.jetbrains.exposed.dao.id.EntityID
import java.util.*

class QuestionDao(id: EntityID<UUID>): CommonColumns<QuestionEntity>(id, QuestionTable) {

    companion object : BaseCompanion<QuestionEntity, QuestionDao>(QuestionTable)

    var questionText by QuestionTable.questionText
    var feedbackType by QuestionTable.feedbackType
    var event by EventDao referencedOn QuestionTable.event
    var index by QuestionTable.index
    val feedback by FeedbackDao referrersOn FeedbackTable.question
    var manager by AccountDao referencedOn QuestionTable.manager

    override fun toModel(): QuestionEntity {
        return QuestionEntity(
            id = id.value,
            questionText = questionText,
            feedbackType = feedbackType,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
            index = index,
            feedback = feedback.map { it.toModel() },
            managerId = manager.id.value,
        )
    }
}
