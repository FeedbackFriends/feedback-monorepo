package dk.example.feedback.model.database

import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.SupportSubmissionKind
import java.time.OffsetDateTime
import java.util.UUID

data class SupportSubmissionEntity(
    val id: UUID,
    val accountId: String,
    val kind: SupportSubmissionKind,
    val rating: Emoji?,
    val message: String?,
    val expectedBehavior: String?,
    val contactEmail: String?,
    val appVersion: String,
    val appBuild: String,
    val osVersion: String,
    val createdAt: OffsetDateTime,
)
