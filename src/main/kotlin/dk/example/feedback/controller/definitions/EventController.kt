package dk.example.feedback.controller.definitions

import ControllerPaths
import dk.example.feedback.constants.Roles
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.payloads.EventInput
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

@Tag(name = "Events", description = "Operations related to events")
@RequestMapping(ControllerPaths.EventUrl)
interface EventController {

    @Operation(summary = "Create a new event")
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    @PostMapping
    fun createEvent(@RequestBody eventInput: EventInput): ManagerEventDto

    @Operation(summary = "Update an existing event")
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    @PutMapping("/{eventId}")
    fun updateEvent(@RequestBody eventInput: EventInput, @PathVariable eventId: UUID): ManagerEventDto

    @Operation(summary = "Delete an event")
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    @DeleteMapping("/{eventId}")
    fun deleteEvent(@PathVariable eventId: UUID, @AuthenticationPrincipal principal: Jwt)

    @Operation(summary = "Join an event")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("join/{pinCode}")
    fun joinEvent(@PathVariable pinCode: String, @AuthenticationPrincipal principal: Jwt): ParticipantEventDto

    @Operation(summary = "Called when a manager navigates to event so new feedback is reset")
    @PostMapping("resetNewFeedback/{eventId}")
    @PreAuthorize("hasAuthority('${Roles.MANAGER}')")
    fun resetNewFeedback(@PathVariable eventId: UUID)
}
