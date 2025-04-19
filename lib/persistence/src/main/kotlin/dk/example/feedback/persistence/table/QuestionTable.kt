package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.QuestionTable.event
import dk.example.feedback.persistence.table.QuestionTable.feedbackType
import dk.example.feedback.persistence.table.QuestionTable.index
import dk.example.feedback.persistence.table.QuestionTable.manager
import dk.example.feedback.persistence.table.QuestionTable.questionText
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for storing feedback questions for events.
 *
 * Each row represents a question created by a manager for an event, specifying the type of feedback to collect.
 *
 * Relationships:
 * - References [AccountTable] (manager) and optionally [EventTable] (event).
 * - Deleting a manager or event cascades and removes their questions.
 *
 * Columns:
 * @property questionText The question text.
 * @property feedbackType The type of feedback ([FeedbackType]).
 * @property manager Foreign key to [AccountTable.id] for the manager.
 * @property event Optional foreign key to [EventTable.id].
 * @property index The order of the question in the event.
 */
object QuestionTable: CommonColumnsTbl("question") {
    val questionText = varchar("question_text", 255)
    val feedbackType = enumerationByName("feedback_type", 255, FeedbackType::class)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val event = optReference(name = "event_id", EventTable, onDelete = ReferenceOption.SET_NULL)
    val index = integer("index")
}
