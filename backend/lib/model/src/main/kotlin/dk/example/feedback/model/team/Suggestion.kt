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
    val trials: List<SuggestionTrial> = emptyList(),
    val evaluations: List<SuggestionEvaluation> = emptyList(),
    val outcomes: List<SuggestionOutcome> = emptyList(),
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

// Immutable revisions; current assignment identifiers never cross the employee boundary.
data class SuggestionTrial(
    val id: UUID,
    val revision: Int,
    val decisionId: UUID,
    val change: String,
    val intendedBenefit: String,
    val responsibleName: String,
    val needsReassignment: Boolean,
    val startDate: String,
    val endDate: String,
    val followUpDate: String,
    val publishedAt: Long,
)


enum class EvaluationAnswer { Better, Unchanged, Worse, CannotAssess }
enum class EvaluationSummary { Improved, Mixed, NotImproved, InsufficientResponses }
enum class TrialOutcome { Continue, Adjust, Stop }
data class SuggestionEvaluation(
    val id: UUID,
    val trialId: UUID,
    val closesAt: Long,
    val closed: Boolean,
    val eligible: Boolean,
    val myAnswer: EvaluationAnswer?,
    val summary: EvaluationSummary?,
)
data class SuggestionOutcome(
    val id: UUID,
    val trialId: UUID,
    val outcome: TrialOutcome,
    val explanation: String,
    val publishedAt: Long,
)
