package dk.example.feedback.model.database

import dk.example.feedback.model.enumerations.ActivityRunMode
import java.time.OffsetDateTime
import java.util.UUID

data class ActivityEntity(
    val id: UUID,
    val title: String,
    val agenda: String?,
    val runMode: ActivityRunMode,
    val sendEmails: Boolean,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime,
    val questions: List<QuestionEntity>,
    val invites: List<ActivityInviteEntity>,
    val manager: AccountEntity,
)
