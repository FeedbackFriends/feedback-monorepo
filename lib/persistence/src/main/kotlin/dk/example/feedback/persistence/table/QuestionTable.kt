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
 * Table definition for questions used in feedback events.
 *
 * This table stores the questions that managers can create for their events.
 * Each question is associated with a specific event and manager, and defines
 * the type of feedback that can be collected for it.
 *
 * The table inherits common columns from [CommonColumnsTbl] including:
 * - `id`: Unique identifier for the question
 * - `created_at`: Timestamp when the question was created
 * - `updated_at`: Timestamp when the question was last modified
 *
 * @property questionText The actual text of the question. Maximum length: 255 characters.
 * @property feedbackType The type of feedback that can be collected for this question,
 *                       represented by the [FeedbackType] enumeration.
 * @property manager A foreign key reference to the manager's account in [AccountTable].
 *                   When a manager is deleted, all their questions are automatically
 *                   deleted due to the CASCADE delete option.
 * @property event A foreign key reference to the associated event in [EventTable].
 *                 When an event is deleted, all its questions are automatically
 *                 deleted due to the CASCADE delete option.
 * @property index The position of the question in the event's question sequence.
 *                 Used for maintaining the order of questions within an event.
 */
object QuestionTable: CommonColumnsTbl("question") {
    val questionText = varchar("question_text", 255)
    val feedbackType = enumerationByName("feedback_type", 255, FeedbackType::class)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val event = reference(name = "event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    val index = integer("index")
}
