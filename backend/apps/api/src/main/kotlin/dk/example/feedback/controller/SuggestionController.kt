package dk.example.feedback.controller

import dk.example.feedback.persistence.repo.SuggestionRepo
import dk.example.feedback.model.team.SuggestionDecisionStatus
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

    private fun text(value: String): String = value.trim().also {
        if (it.isEmpty() || it.length > 1000) throw ResponseStatusException(HttpStatus.BAD_REQUEST)
    }
}
