package dk.example.feedback.model.team

import java.util.UUID

// Caller-specific flags never identify another employee.
data class Suggestion(
    val id: UUID,
    val problem: String,
    val impact: String,
    val solution: String?,
    val supportCount: Long,
    val supportedByMe: Boolean,
    val mine: Boolean,
)

// Leaders review content only, without author or reporter identity or activity metadata.
data class ReportedSuggestion(val id: UUID, val problem: String, val impact: String, val solution: String?)
