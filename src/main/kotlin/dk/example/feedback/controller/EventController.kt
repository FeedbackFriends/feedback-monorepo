package dk.example.feedback.controller

import dk.example.feedback.model.EventInput
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.service.EventService
import dk.example.feedback.service.SessionService
import org.springframework.web.bind.annotation.*
import java.util.*
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt

@RestController
@RequestMapping(ControllerPaths.EventUrl)
class EventController(
    val eventService: EventService,
) {

    @PostMapping
    @PreAuthorize("hasAuthority('Manager')")
    fun createEvent(@RequestBody eventInput: EventInput, @AuthenticationPrincipal principal: Jwt): ManagerEventDto {
        return eventService.create(eventInput = eventInput, accountId = principal.subject)
    }

    @PutMapping("/{eventId}")
    @PreAuthorize("hasAuthority('Manager')")
    fun updateEvent(@RequestBody eventInput: EventInput, @PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt): ManagerEventDto {
        val accountId = principal.subject
        return eventService.update(eventInput = eventInput, eventId = eventId, accountId = accountId)
    }

    @DeleteMapping("/{eventId}")
    @PreAuthorize("hasAuthority('Manager')")
    fun deleteEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return eventService.delete(eventId = eventId, accountId = principal.subject)
    }

    @PostMapping("attending/{eventId}")
    @PreAuthorize("hasAuthority('Manager') or hasAuthority('Participant')")
    fun acceptEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt): ParticipantEventDto {
        return eventService.acceptEventInvite(eventId = eventId, accountId = principal.subject)
    }
}
