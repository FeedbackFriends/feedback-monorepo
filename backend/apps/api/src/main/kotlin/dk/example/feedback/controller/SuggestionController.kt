package dk.example.feedback.controller

import dk.example.feedback.persistence.repo.SuggestionRepo
import dk.example.feedback.model.team.*
import dk.example.feedback.service.TeamService
import org.springframework.http.HttpStatus
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.*
import org.springframework.web.server.ResponseStatusException
import java.util.UUID
import java.time.LocalDate
import java.time.format.DateTimeParseException
import dk.example.feedback.model.team.SuggestionInbox

data class CreateSuggestionInput(val id: UUID, val problem: String, val impact: String, val solution: String? = null)
data class SuggestionSupportInput(val supported: Boolean)
data class ModerateSuggestionInput(val remove: Boolean)
data class PublishSuggestionDecisionInput(val id: UUID, val expectedRevision: Int, val status: SuggestionDecisionStatus,
    val explanation: String, val responsibleId: String, val responsibleName: String, val followUpDate: String? = null)

data class PublishSuggestionTrialInput(val id: UUID, val expectedRevision: Int, val expectedDecisionId: UUID,
    val change: String, val intendedBenefit: String, val responsibleId: String, val responsibleName: String,
    val startDate: String, val endDate: String, val followUpDate: String)

data class OpenSuggestionEvaluationInput(val id: UUID, val trialId: UUID, val closesAt: Long)
data class AnswerSuggestionEvaluationInput(val answer: EvaluationAnswer)
data class PublishSuggestionOutcomeInput(val id: UUID, val trialId: UUID, val outcome: TrialOutcome, val explanation: String)

@RestController
@RequestMapping("/teams/{teamId}/suggestions")
@PreAuthorize("isAuthenticated()")
class SuggestionController(private val suggestions: SuggestionRepo, private val teams: TeamService) {
    @GetMapping
    fun listSuggestions(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID) = suggestions.list(teams.actor(jwt), teamId)

    @PostMapping
    fun createSuggestion(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @RequestBody input: CreateSuggestionInput) =
        suggestions.create(teams.actor(jwt), teamId, input.id, text(input.problem), text(input.impact), input.solution?.trim()?.takeIf { it.isNotEmpty() }?.let(::text))

    @PutMapping("/{suggestionId}/support")
    fun setSuggestionSupport(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @RequestBody input: SuggestionSupportInput) = suggestions.support(teams.actor(jwt), teamId, suggestionId, input.supported)

    @DeleteMapping("/{suggestionId}")
    fun withdrawSuggestion(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID) =
        suggestions.withdraw(teams.actor(jwt), teamId, suggestionId)

    @PostMapping("/{suggestionId}/report")
    fun reportSuggestion(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID) =
        suggestions.report(teams.actor(jwt), teamId, suggestionId)

    @GetMapping("/reports")
    fun reportedSuggestions(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID) = suggestions.reports(teams.actor(jwt), teamId)

    @PostMapping("/{suggestionId}/moderation")
    fun moderateSuggestion(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @RequestBody input: ModerateSuggestionInput) = suggestions.moderate(teams.actor(jwt), teamId, suggestionId, input.remove)

    @GetMapping("/inbox")
    fun suggestionInbox(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID) = suggestions.inbox(teams.actor(jwt), teamId)

    @PostMapping("/{suggestionId}/decisions")
    fun publishSuggestionDecision(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @RequestBody input: PublishSuggestionDecisionInput): SuggestionInbox {
        if (input.expectedRevision < 0 || input.expectedRevision == Int.MAX_VALUE || input.responsibleId.isBlank() ||
            input.responsibleName.trim().length > 255) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        val date = input.followUpDate?.let {
            if (it.length != 10) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
            try { LocalDate.parse(it).also { parsed ->
                if (parsed.toString() != it || parsed.year !in 1..9999) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
            } } catch (_: DateTimeParseException) { throw ResponseStatusException(HttpStatus.BAD_REQUEST) }
        }
        if (input.status != SuggestionDecisionStatus.Declined && date == null) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        return suggestions.publishDecision(teams.actor(jwt), teamId, suggestionId, input.id, input.expectedRevision,
            input.status, text(input.explanation), input.responsibleId, text(input.responsibleName), input.followUpDate)
    }

    @PostMapping("/{suggestionId}/trials")
    fun publishSuggestionTrial(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @RequestBody input: PublishSuggestionTrialInput): SuggestionInbox {
        if (input.expectedRevision < 0 || input.expectedRevision == Int.MAX_VALUE || input.responsibleId.isBlank() ||
            input.responsibleName.trim().length > 255) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        val start = calendarDate(input.startDate)
        val end = calendarDate(input.endDate)
        val followUp = calendarDate(input.followUpDate)
        if (end < start || followUp < end) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        return suggestions.publishTrial(teams.actor(jwt), teamId, suggestionId, input.id, input.expectedRevision,
            input.expectedDecisionId, text(input.change), text(input.intendedBenefit), input.responsibleId,
            text(input.responsibleName), input.startDate, input.endDate, input.followUpDate)
    }

    @PostMapping("/{suggestionId}/evaluations")
    fun openSuggestionEvaluation(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @RequestBody input: OpenSuggestionEvaluationInput): SuggestionInbox {
        if (input.closesAt !in 1..253402300799999L) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        return suggestions.openEvaluation(teams.actor(jwt), teamId, suggestionId, input.id, input.trialId, input.closesAt)
    }

    @PutMapping("/{suggestionId}/evaluations/{evaluationId}/answer")
    fun answerSuggestionEvaluation(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @PathVariable evaluationId: UUID, @RequestBody input: AnswerSuggestionEvaluationInput) =
        suggestions.answerEvaluation(teams.actor(jwt), teamId, suggestionId, evaluationId, input.answer)

    @PostMapping("/{suggestionId}/outcomes")
    fun publishSuggestionOutcome(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable suggestionId: UUID,
        @RequestBody input: PublishSuggestionOutcomeInput) =
        suggestions.publishOutcome(teams.actor(jwt), teamId, suggestionId, input.id, input.trialId, input.outcome, text(input.explanation))

    private fun calendarDate(value: String): LocalDate {
        if (value.length != 10) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        val date = try { LocalDate.parse(value) } catch (_: DateTimeParseException) { throw ResponseStatusException(HttpStatus.BAD_REQUEST) }
        if (date.year !in 1..9999 || date.toString() != value) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
        return date
    }

    private fun text(value: String): String = value.trim().also {
        if (it.isEmpty() || it.length > 1000) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
    }
}
