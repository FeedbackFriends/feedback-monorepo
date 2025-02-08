package dk.example.feedback.controller

import ControllerPaths
import dk.example.feedback.controller.definitions.EventController
import dk.example.feedback.model.dto.ManagerEventDto
import dk.example.feedback.model.dto.ParticipantEventDto
import dk.example.feedback.model.payloads.EventInput
import dk.example.feedback.service.EventService
import java.util.*
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping(ControllerPaths.EventUrl)
class EventControllerImpl(
    val eventService: EventService,
) : EventController {

    override fun createEvent(eventInput: EventInput): ManagerEventDto {
        return eventService.createEvent(eventInput = eventInput)
    }

    override fun updateEvent(eventInput: EventInput, eventId: UUID): ManagerEventDto {
        return eventService.updateEvent(eventInput = eventInput, eventId = eventId)
    }

    override fun deleteEvent(eventId: UUID, principal: Jwt) {
        return eventService.deleteEvent(eventId = eventId)
    }

    override fun joinEvent(pinCode: String, principal: Jwt): ParticipantEventDto {
        return eventService.joinEvent(pinCode = pinCode)
    }

    override fun resetNewFeedback(eventId: UUID): Unit {
        return eventService.resetNewFeedback(eventId = eventId)
    }
}

