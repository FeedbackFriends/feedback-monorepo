package dk.example.feedback.dto

import java.time.OffsetDateTime
import java.util.UUID

data class SupportSubmissionReceipt(val id: UUID, val receivedAt: OffsetDateTime)
