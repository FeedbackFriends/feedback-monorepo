package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.Opinion
import dk.example.feedback.model.enumerations.ThumbsUpThumpsDown
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

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
    val isNew = bool("is_new")
}
