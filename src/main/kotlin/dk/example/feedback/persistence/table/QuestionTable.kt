package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object QuestionTable: CommonColumnsTbl("question") {
    val questionText = varchar("question_text", 255)
    val feedbackType = enumerationByName("feedback_type", 255, FeedbackType::class)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val event = reference(name = "event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    val index = integer("index")
}
