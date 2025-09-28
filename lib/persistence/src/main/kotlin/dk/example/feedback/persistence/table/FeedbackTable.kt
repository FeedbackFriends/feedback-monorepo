package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import dk.example.feedback.persistence.table.FeedbackTable.comment
import dk.example.feedback.persistence.table.FeedbackTable.emoji
import dk.example.feedback.persistence.table.FeedbackTable.manager
import dk.example.feedback.persistence.table.FeedbackTable.zeroToTen
import dk.example.feedback.persistence.table.FeedbackTable.opinion
import dk.example.feedback.persistence.table.FeedbackTable.participant
import dk.example.feedback.persistence.table.FeedbackTable.question
import dk.example.feedback.persistence.table.FeedbackTable.seenByManager
import dk.example.feedback.persistence.table.FeedbackTable.thumbsUpThumpsDown
import dk.example.feedback.persistence.table.FeedbackTable.type
import org.jetbrains.exposed.sql.ReferenceOption

/**
 * Table for storing feedback entries.
 *
 * Each row represents a user's feedback on a specific question, supporting multiple feedback types (text, emoji, rating, etc).
 * Feedback is linked to questions, managers, and optionally participants.
 *
 * Relationships:
 * - References [QuestionTable], [AccountTable] (manager), and optionally [AccountTable] (participant).
 * - Deleting a question, manager, or participant cascades and removes corresponding feedback.
 *
 * Columns:
 * @property type The type of feedback ([FeedbackType]).
 * @property comment Optional textual comment.
 * @property emoji Optional emoji ([Emoji]).
 * @property thumbsUpThumpsDown Optional thumbs up/down ([ThumbsUpThumpsDown]).
 * @property zeroToTen Optional numeric rating (1-10).
 * @property opinion Optional opinion ([Opinion]).
 * @property question Foreign key to [QuestionTable.id].
 * @property manager Foreign key to [AccountTable.id] for the manager.
 * @property participant Optional foreign key to [AccountTable.id] for the participant.
 * @property seenByManager Whether the manager has seen this feedback.
 */
object FeedbackTable: CommonColumnsTbl("feedback") {
    val type = enumerationByName("type", 14, FeedbackType::class)
    val comment = varchar("comment", 255).nullable()
    val emoji = enumerationByName("emoji", 255, Emoji::class).nullable()
    val thumbsUpThumpsDown = enumerationByName("thumbs_up_thumps_down", 14, ThumbsUpThumpsDown::class).nullable()
    val zeroToTen = integer("zero_to_ten").nullable()
    val opinion = enumerationByName("opinion", 255, Opinion::class).nullable()
    val question = reference("question_id", QuestionTable, onDelete = ReferenceOption.CASCADE)
    val manager = reference(name = "manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = optReference(name = "participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE).default(null)
    val seenByManager = bool("seen_by_manager")
}
