package dk.example.feedback.persistence.table

import dk.example.feedback.model.*
import dk.example.feedback.persistence.dao.CommonColumnsTbl
import dk.example.feedback.persistence.table.QuestionTable.default
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.sql.Column
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object AccountTable: IdTable<String>("account") {

    override val id: Column<EntityID<String>> = varchar("id", 255).entityId()
    override val primaryKey = PrimaryKey(id)

    val name = varchar("name", 255).nullable() // is never null if user is not anonymous
    val fcmToken = varchar("fcm_token", 255).nullable()
    val email =  varchar("email", 255).nullable() // is never null if user is not anonymous
    val phoneNumber = varchar("phone_number", 255).nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    val ratingPrompted = bool("rating_prompted").default(false)
}

object EventTable: CommonColumnsTbl("event") {
    val title = varchar("title", 255)
    val agenda = varchar("agenda", 255).nullable()
    val date = timestampWithTimeZone("date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = varchar("location", 255).nullable().default(null)
    val pinCode = varchar("pin_code", 255)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
}

object QuestionTable: CommonColumnsTbl("question") {
    val questionText = varchar("question_text", 255)
    val feedbackType = enumerationByName("feedback_type", 255, FeedbackType::class)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val event = reference(name = "event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    val index = integer("index")
}

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
    val isNew = bool("is_new").default(true)
}

object EventParticipantTable: CommonColumnsTbl("event_participant") {
    val event = reference("event_id", EventTable.id, ReferenceOption.CASCADE)
    val participant = reference("participant_id", AccountTable.id, ReferenceOption.CASCADE)
    val feedback = reference("feedback_id", FeedbackTable.id, ReferenceOption.SET_NULL).nullable()
}
