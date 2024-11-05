package dk.example.feedback.controller

import dk.example.feedback.model.EventInput
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.service.EventService
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
        TODO("Check if the account is the owner of the event")
//        accountService.throwExceptionIfAccountExists(accountId)
        return eventService.update(eventInput = eventInput, eventId = eventId)
    }

    @DeleteMapping("/{eventId}")
    @PreAuthorize("hasAuthority('Manager')")
    fun deleteEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt) {
        TODO("Check if the account is the owner of the event")
//        accountService.throwExceptionIfAccountExists(principal.subject)
        return eventService.delete(eventId = eventId)
    }
}
