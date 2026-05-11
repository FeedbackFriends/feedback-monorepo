package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.QuestionTable.feedbackType
import dk.example.feedback.persistence.table.QuestionTable.index
import dk.example.feedback.persistence.table.QuestionTable.manager
import dk.example.feedback.persistence.table.QuestionTable.questionText
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for storing feedback questions for activities and event snapshots.
 *
 * Each row represents either:
 * - a canonical question owned by an activity, or
 * - a question snapshot copied into a event at creation time.
 *
 * Relationships:
 * - References [AccountTable] (manager), optionally [ActivityTable], and optionally [EventTable].
 * - Deleting a manager, activity, or event cascades and removes related questions.
 *
 * Columns:
 * @property questionText The question text.
 * @property feedbackType The type of feedback ([FeedbackType]).
 * @property manager Foreign key to [AccountTable.id] for the manager.
 * @property activity Optional foreign key to [ActivityTable.id].
 * @property event Optional foreign key to [EventTable.id].
 * @property activityQuestionId Stable canonical identifier copied from the activity-level question.
 * @property index The order of the question in the owning activity/event.
 */
object QuestionTable: CommonColumnsTbl("question") {
    val questionText = varchar("question_text", 255)
    val feedbackType = enumerationByName("feedback_type", 255, FeedbackType::class)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val activity = optReference(name = "activity_id", ActivityTable, onDelete = ReferenceOption.CASCADE)
    val event = optReference(name = "event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    val activityQuestionId = uuid("activity_question_id").nullable()
    val index = integer("index")
}
