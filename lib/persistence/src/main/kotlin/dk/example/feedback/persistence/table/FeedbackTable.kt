package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.FeedbackTable.comment
import dk.example.feedback.persistence.table.FeedbackTable.emoji
import dk.example.feedback.persistence.table.FeedbackTable.manager
import dk.example.feedback.persistence.table.FeedbackTable.oneToTen
import dk.example.feedback.persistence.table.FeedbackTable.opinion
import dk.example.feedback.persistence.table.FeedbackTable.participant
import dk.example.feedback.persistence.table.FeedbackTable.question
import dk.example.feedback.persistence.table.FeedbackTable.seenByManager
import dk.example.feedback.persistence.table.FeedbackTable.thumbsUpThumpsDown
import dk.example.feedback.persistence.table.FeedbackTable.type
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table definition for feedback entries in the system.
 *
 * This table stores the details of feedback provided by accounts related to questions.
 * It supports various feedback forms including textual comments, emojis, thumbs up/thumbs down,
 * numeric ratings, and opinions. Each feedback entry must be associated with a question and a manager,
 * while participant association is optional.
 *
 * The table inherits common columns from [CommonColumnsTbl] including:
 * - `id`: Unique identifier for the feedback entry
 * - `created_at`: Timestamp when the feedback was created
 * - `updated_at`: Timestamp when the feedback was last modified
 *
 * @property type The type of feedback, represented by the [FeedbackType] enumeration. Required field.
 * @property comment An optional textual comment associated with the feedback. Maximum length: 255 characters.
 * @property emoji An optional emoji representing the feedback sentiment from the [Emoji] enumeration.
 * @property thumbsUpThumpsDown An optional feedback indicator using the [ThumbsUpThumpsDown] enumeration.
 * @property oneToTen An optional numerical rating on a scale from 1 to 10.
 * @property opinion An optional opinion feedback using the [Opinion] enumeration.
 * @property question A foreign key reference to the associated question in [QuestionTable]. Deletion cascades.
 * @property manager A foreign key reference to the manager's account in [AccountTable]. Deletion cascades.
 * @property participant An optional foreign key reference to the participant's account in [AccountTable]. Deletion cascades.
 * @property seenByManager Boolean flag indicating whether the feedback has been seen by the manager. Defaults to false.
 */
object FeedbackTable: CommonColumnsTbl("feedback") {
    val type = enumerationByName("type", 14, FeedbackType::class)
    val comment = varchar("comment", 255).nullable()
    val emoji = enumerationByName("emoji", 255, Emoji::class).nullable()
    val thumbsUpThumpsDown = enumerationByName("thumbs_up_thumps_down", 14, ThumbsUpThumpsDown::class).nullable()
    val oneToTen = integer("one_to_ten").nullable()
    val opinion = enumerationByName("opinion", 255, Opinion::class).nullable()
    val question = reference("question_id", QuestionTable, onDelete = ReferenceOption.CASCADE)
    val manager = reference(name = "manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = optReference(name = "participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE).default(null)
    val seenByManager = bool("seen_by_manager")
}
