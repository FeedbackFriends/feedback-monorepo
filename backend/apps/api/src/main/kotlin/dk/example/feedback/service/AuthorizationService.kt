package dk.example.feedback.service

import dk.example.feedback.model.database.ActivityEntity
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.exceptions.CannotGiveFeedbackToSelfException
import dk.example.feedback.model.exceptions.CannotJoinOwnEventException
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import java.util.UUID
import org.springframework.stereotype.Service

@Service
class AuthorizationService(
    private val activityRepo: ActivityRepo,
    private val eventRepo: EventRepo,
) {

    fun requireSelf(targetAccountId: String, actorAccountId: String) {
        if (targetAccountId != actorAccountId) {
            throw ForbiddenResourceAccessException("User does not have access to this resource")
        }
    }

    fun requireActivityManager(activityId: UUID, actorAccountId: String): ActivityEntity {
        val activity = activityRepo.getActivity(activityId)
        requireSelf(targetAccountId = activity.manager.id, actorAccountId = actorAccountId)
        return activity
    }

    fun requireEventManager(eventId: UUID, actorAccountId: String): EventEntity {
        val event = eventRepo.getEvent(eventId)
        requireSelf(targetAccountId = event.manager.id, actorAccountId = actorAccountId)
        return event
    }

    fun requireNotEventManagerForJoin(event: EventEntity, actorAccountId: String) {
        if (event.manager.id == actorAccountId) {
            throw CannotJoinOwnEventException()
        }
    }

    fun requireNotEventManagerForFeedback(event: EventEntity, actorAccountId: String) {
        if (event.manager.id == actorAccountId) {
            throw CannotGiveFeedbackToSelfException()
        }
    }
}
