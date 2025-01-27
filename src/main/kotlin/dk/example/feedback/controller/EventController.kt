package dk.example.feedback.controller

import ControllerPaths
import dk.example.feedback.constants.Roles
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.payloads.EventInput
import dk.example.feedback.service.EventService
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
@RequestMapping(ControllerPaths.EventUrl)
class EventController(
    val eventService: EventService,
) {

    @PostMapping
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    fun createEvent(@RequestBody eventInput: EventInput): ManagerEventDto {
        return eventService.createEvent(eventInput = eventInput)
    }

    @PutMapping("/{eventId}")
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    fun updateEvent(@RequestBody eventInput: EventInput, @PathVariable eventId: UUID): ManagerEventDto {
        return eventService.updateEvent(eventInput = eventInput, eventId = eventId)
    }

    @DeleteMapping("/{eventId}")
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    fun deleteEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return eventService.deleteEvent(eventId = eventId)
    }

    @PostMapping("join/{eventCode}")
    @PreAuthorize("isAuthenticated()")
    fun acceptEvent(@PathVariable eventCode: String, @AuthenticationPrincipal principal: Jwt): ParticipantEventDto {
        return eventService.joinEvent(pinCode = eventCode)
    }

    @PostMapping
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    fun resetNewFeedback(@RequestBody evendId: UUID): ManagerEventDto {
        return eventService.resetNewFeedback(eventId = evendId)
    }
}

