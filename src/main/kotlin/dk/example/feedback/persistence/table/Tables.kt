package dk.example.feedback.persistence.table

import dk.example.feedback.model.*
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IdTable
import org.jetbrains.exposed.dao.id.UUIDTable
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
//    val role = enumerationByName("role", 255, Role::class).nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    val ratingPrompted = bool("rating_prompted").default(false)
}

object EventTable: UUIDTable("event") {
    val title = varchar("title", 255)
    val agenda = varchar("agenda", 255).nullable()
    val date = timestampWithTimeZone("date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = varchar("location", 255).nullable().default(null)
    val pinCode = varchar("pin_code", 255)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
    val team = optReference("team_id", TeamTable, onDelete = ReferenceOption.SET_NULL).default(null)
    val newFeedback = integer("new_feedback").default(0)
}

object QuestionTable: UUIDTable("question") {
    val questionText = varchar("question_text", 255)
    val feedbackType = enumerationByName("feedback_type", 255, FeedbackType::class)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
    val event = reference(name = "event_id", EventTable, onDelete = ReferenceOption.CASCADE)
    val index = integer("index")
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
}

object FeedbackTable: UUIDTable("feedback") {
    val type = enumerationByName("type", 14, FeedbackType::class)
    val comment = varchar("comment", 255).nullable()
    val emoji = enumerationByName("emoji", 255, Emoji::class).nullable()
    val thumbsUpThumpsDown = enumerationByName("thumbs_up_thumps_down", 14, ThumbsUpThumpsDown::class).nullable()
    val oneToTen = integer("one_to_ten").nullable()
    val opinion = enumerationByName("opinion", 255, Opinion::class).nullable()
    val createdAt = timestampWithTimeZone("created_at")
    val question = reference("question_id", QuestionTable, onDelete = ReferenceOption.CASCADE)
    val manager = reference(name = "manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val participant = optReference(name = "participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE).default(null)
}

object TeamTable: UUIDTable("team") {
    val name = varchar("name", 255)
    val manager = reference(name = "manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val createdAt = timestampWithTimeZone("created_at")
    val updatedAt = timestampWithTimeZone("updated_at")
}

object TeamMemberTable: UUIDTable("team_member") {
    val team = reference("team_id", TeamTable.id, ReferenceOption.CASCADE)
    val account = reference("member_id", AccountTable.id, ReferenceOption.CASCADE)
    val status = enumerationByName("status", 255, TeamMemberStatus::class)
//    val hasBeenNotified = bool("has_been_notified").default(false)
}

//object TeamNotificationTable: UUIDTable("notification") {
//    val notificationType = enumerationByName("notification_type", 255, NotificationType::class)
//    val createdAt = timestampWithTimeZone("created_at")
//    val team = optReference("team_id", TeamTable.id, onDelete = ReferenceOption.SET_NULL)
//    val participant = optReference("participant_id", AccountTable.id, onDelete = ReferenceOption.SET_NULL)
//    val manager = reference("manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
//    val isSeenBefore = bool("is_seen_before").default(false)
//}

//enum class NotificationType {
//    /**
//     * Eksempel:
//     * Henrik har accepteret team invitationen for det specielle team
//     */
//    TEAM_INVITE_ACCEPTED,
//    /**
//     * Eksmpel:_
//     * Henrik har declined team invitationen for det specielle team
//     */
//    TEAM_INVITE_DECLINED,
//
//    // Participant
//    /**
//     * Du er blevet inviteret til et team bla bla
//     */
//    TEAM_INVITE,
//    /**
//     * Team bla bla er slettet
//     */
//    TEAM_DELETED,
//    TEAM_NAME_CHANGED
//}

//object EventNotificationTable: UUIDTable("notification") {
//    val notificationType = enumerationByName("notification_type", 255, NotificationType::class)
//    val createdAt = timestampWithTimeZone("created_at")
//    val team = optReference("team_id", TeamTable.id, onDelete = ReferenceOption.SET_NULL)
//    val participant = optReference("participant_id", AccountTable.id, onDelete = ReferenceOption.SET_NULL)
//    val manager = reference("manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
//    val isSeenBefore = bool("is_seen_before").default(false)
//}

//object ManagerNotificationTable: UUIDTable("manager_notification") {
//    val managerNotificationType = enumerationByName("manager_notification_type", 255, ManagerNotificationType::class)
//    val createdAt = timestampWithTimeZone("created_at")
//    val team = optReference("team_id", TeamTable.id, onDelete = ReferenceOption.SET_NULL)
//    val participant = optReference("participant_id", AccountTable.id, onDelete = ReferenceOption.SET_NULL)
//    val manager = reference("manager_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
//    val event = optReference("event_id", EventTable, onDelete = ReferenceOption.SET_NULL)
//    val isNew = bool("is_new").default(true)
//}
//
//enum class ManagerNotificationType {
//    /**
//     * Henrik har accepteret team invitationen for det specielle team
//     */
//    TEAM_INVITE_ACCEPTED,
//    /**
//     * Henrik har declined team invitationen for det specielle team
//     */
//    TEAM_INVITE_DECLINED,
//    /**
//     * X har modtaget ny feedback
//     */
//    NEW_FEEDBACK,
//}
//
//object ParticipantNotificationTable: UUIDTable("participant_notification") {
//    val participantNotificationType = enumerationByName("participant_notification_type", 255, ParticipantNotificationType::class)
//    val createdAt = timestampWithTimeZone("created_at")
//    val team = optReference("team_id", TeamTable.id, onDelete = ReferenceOption.SET_NULL)
//    val participant = reference("participant_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
//    val manager = optReference("manager_id", AccountTable.id, onDelete = ReferenceOption.SET_NULL)
//    val event = optReference("event_id", EventTable, onDelete = ReferenceOption.SET_NULL)
//    val isNew = bool("is_new").default(true)
//}
//
//enum class ParticipantNotificationType {
//    /**
//     * Du er blevet inviteret til et team bla bla
//     */
//    TEAM_INVITE,
//    /**
//     * Team bla bla er slettet
//     */
//    TEAM_DELETED,
//    /**
//     * Team bla bla har skiftet navn til bla bla
//     */
//    TEAM_NAME_CHANGED,
//    /**
//     * Du har ikke givet feedback til event bla bla endnu. Giv feedback nu!
//     */
//    remember_feedback,
//    /**
//     * X har oprettet et nyt event X d. 13. august kl. 13:00
//     */
//}
//
//object NotificationTable: UUIDTable("otification") {
//    val notificationType = enumerationByName("notification_type", 255, NotificationType::class)
//    val createdAt = timestampWithTimeZone("created_at")
//    val team = optReference("team_id", TeamTable.id, onDelete = ReferenceOption.SET_NULL)
//    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
//    val event = optReference("event_id", EventTable, onDelete = ReferenceOption.SET_NULL)
//    val isNew = bool("is_new").default(true)
//}
//
//enum class NotificationType {
//    /**
//     * Henrik har accepteret team invitationen for det specielle team
//     */
//    TEAM_INVITE_ACCEPTED,
//    /**
//     * Henrik har declined team invitationen for det specielle team
//     */
//    TEAM_INVITE_DECLINED,
//    /**
//     * X har modtaget ny feedback
//     */
//    NEW_FEEDBACK,
//    /**
//     * Du er blevet inviteret til et team bla bla
//     */
//    TEAM_INVITE,
//    /**
//     * Team bla bla er slettet
//     */
//    TEAM_DELETED,
//    /**
//     * Team bla bla har skiftet navn til bla bla
//     */
//    TEAM_NAME_CHANGED,
//    /**
//     * Du har ikke givet feedback til event bla bla endnu. Giv feedback nu!
//     */
//    remember_feedback,
//    /**
//     * X har oprettet et nyt event X d. 13. august kl. 13:00
//     */
//    NEW_EVENT,
//}
//
//object TeamNotificationParticipantTable: UUIDTable("team_notification_participant") {
//    val createdAt = timestampWithTimeZone("created_at")
//    val participant = reference("participant_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//    val team = reference("team_id", TeamTable, onDelete = ReferenceOption.CASCADE)
//    val type = enumerationByName("type", 255, TeamNotificationParticipantType::class)
//}
//
//enum class TeamNotificationParticipantType {
//    TEAM_INVITE,
//    TEAM_NAME_CHANGED,
//}
//
//object TeamNotificationManagerTable: UUIDTable("team_notification_manager") {
//    val createdAt = timestampWithTimeZone("created_at")
//    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//    val participant = reference("participant_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//    val team = reference("team_id", TeamTable, onDelete = ReferenceOption.CASCADE)
//    val type = enumerationByName("type", 255, TeamNotificationManagerType::class)
//    val participantNotification = reference("participant_notification_id", ParticipantNotificationTable, onDelete = ReferenceOption.CASCADE)
//}
//
//enum class TeamNotificationManagerType {
//    /**
//     * Henrik har accepteret team invitationen for det specielle team
//     */
//    TEAM_INVITE_ACCEPTED,
//    /**
//     * Henrik har declined team invitationen for det specielle team
//     */
//    TEAM_INVITE_DECLINED,
//}
//
//object EventNotificationParticipantTable: UUIDTable("event_notification_participant") {
//    val createdAt = timestampWithTimeZone("created_at")
//    val participant = reference("participant_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//    val event = reference("event_id", EventTable, onDelete = ReferenceOption.CASCADE)
//    val type = enumerationByName("type", 255, EventNotificationParticipantType::class)
//}
//
//enum class EventNotificationParticipantType {
//    /**
//     * Du har ikke givet feedback til event bla bla endnu. Giv feedback nu!
//      */
//    REMEMBER_FEEDBACK,
//}
//
//object EventNotificationManagerTable: UUIDTable("event_notification_manager") {
//    val createdAt = timestampWithTimeZone("created_at")
//    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//    val event = reference("event_id", EventTable, onDelete = ReferenceOption.CASCADE)
//    val type = enumerationByName("type", 255, EventNotificationManagerType::class)
//}
//
//enum class EventNotificationManagerType {
//    /**
//     * X har modtaget ny feedback! Tjek det ud
//      */
//    FEEDBACK_RECEIVED,
//}
//
//object InvitationTable: UUIDTable("invitation") {
//    val createdAt = timestampWithTimeZone("created_at")
//    val team = reference("team_id", TeamTable, onDelete = ReferenceOption.CASCADE)
//    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//    val invitedEmail = varchar("invited_email", 255)
//    val invitedAccount = optReference("invited_account_id", AccountTable, onDelete = ReferenceOption.CASCADE)
//}