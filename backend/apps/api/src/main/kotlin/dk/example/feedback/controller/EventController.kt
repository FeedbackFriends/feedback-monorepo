package dk.example.feedback.controller

import dk.example.feedback.dto.EventWrapperDto
import dk.example.feedback.dto.ParticipantEventDto
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.payloads.EventInput
import dk.example.feedback.service.EventService
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

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @PostMapping
    fun createEvent(@RequestBody eventInput: EventInput, @AuthenticationPrincipal principal: Jwt): EventWrapperDto {
        return eventService.createEvent(eventInput = eventInput, jwt = principal)
    }

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @PutMapping("/{eventId}")
    fun updateEvent(
        @RequestBody eventInput: EventInput,
        @PathVariable eventId: UUID,
        @AuthenticationPrincipal principal: Jwt
    ): EventWrapperDto {
        return eventService.updateEvent(eventInput = eventInput, eventId = eventId, jwt = principal)
    }

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @DeleteMapping("/{eventId}")
    fun deleteEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return eventService.deleteEvent(eventId = eventId, jwt = principal)
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("join/{pinCode}")
    fun joinEvent(@PathVariable pinCode: String, @AuthenticationPrincipal principal: Jwt): ParticipantEventDto {
        return eventService.joinEvent(pinCode = pinCode, jwt = principal)
    }

    @PutMapping("mark-as-seen/{eventId}")
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun markEventAsSeen(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt) {
        return eventService.markEventAsSeen(eventId = eventId, jwt = principal)
    }
}

