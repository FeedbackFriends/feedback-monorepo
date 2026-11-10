package dk.example.feedback.model.team

import java.util.UUID

// Caller-specific flags never identify another employee.
data class Suggestion(
    val id: UUID,
    val problem: String,
    val impact: String,
    val solution: String?,
    val hasFiveSupporters: Boolean,
    val supportedByMe: Boolean,
    val mine: Boolean,
    val decisions: List<SuggestionDecision> = emptyList(),
)

// Leaders review content only, without author or reporter identity or activity metadata.
data class ReportedSuggestion(val id: UUID, val problem: String, val impact: String, val solution: String?)

// Public history deliberately excludes account identifiers.
enum class SuggestionDecisionStatus { Reviewing, Planned, Deferred, Declined }
data class SuggestionDecision(
    val id: UUID,
    val revision: Int,
    val status: SuggestionDecisionStatus,
    val explanation: String,
    val responsibleName: String,
    val followUpDate: String?,
    val publishedAt: Long,
)
data class SuggestionResponsiblePerson(val accountId: String, val name: String?, val email: String?)
data class SuggestionInbox(val suggestions: List<Suggestion>, val responsiblePeople: List<SuggestionResponsiblePerson>)
