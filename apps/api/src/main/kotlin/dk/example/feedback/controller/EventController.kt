package dk.example.feedback.controller

import dk.example.feedback.constants.Roles
import dk.example.feedback.dto.ManagerEventDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.payloads.EventInput
import dk.example.feedback.service.EventService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import java.util.*
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Events")
@RequestMapping("/event")
class EventController(
    val eventService: EventService,
) {

    @PreAuthorize("hasAuthority('${Roles.ORGANIZER}')")
    @PostMapping
    fun createEvent(@RequestBody eventInput: EventInput): ManagerEventDto {
        return eventService.createEvent(eventInput = eventInput)
    }

    @PreAuthorize("hasAuthority('${Roles.ORGANIZER}')")
    @PutMapping("/{eventId}")
    fun updateEvent(@RequestBody eventInput: EventInput, @PathVariable eventId: UUID): ManagerEventDto {
        return eventService.updateEvent(eventInput = eventInput, eventId = eventId)
    }

    @PreAuthorize("hasAuthority('${Roles.ORGANIZER}')")
    @DeleteMapping("/{eventId}")
    fun deleteEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return eventService.deleteEvent(eventId = eventId)
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("join/{pinCode}")
    fun joinEvent(@PathVariable pinCode: String, @AuthenticationPrincipal principal: Jwt): ParticipantEventDto {
        return eventService.joinEvent(pinCode = pinCode)
    }

    @Operation(summary = "Called when a manager navigates to event so new feedback is reset")
    @PutMapping("resetNewFeedback/{eventId}")
    @PreAuthorize("hasAuthority('${Roles.ORGANIZER}')")
    fun resetNewFeedback(@PathVariable eventId: UUID) {
        return eventService.resetNewFeedback(eventId = eventId)
    }
}

