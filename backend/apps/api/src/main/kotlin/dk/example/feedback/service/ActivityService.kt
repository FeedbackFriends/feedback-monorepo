package dk.example.feedback.service

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ActivityInput
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.verifyAccountHasId
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.ActivityQuestionUpsert
import dk.example.feedback.persistence.repo.EventRepo
import java.util.UUID
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class ActivityService(
    private val activityRepo: ActivityRepo,
    private val eventRepo: EventRepo,
) {

    fun createActivity(input: ActivityInput, jwt: Jwt): ActivityDto {
        val activity = activityRepo.persistActivity(
            title = input.title,
            agenda = input.agenda,
            runMode = input.runMode,
            sendEmails = input.sendEmails,
            questions = input.questions.map {
                ActivityQuestionUpsert(
                    id = it.id,
                    questionText = it.questionText,
                    feedbackType = it.feedbackType,
                )
            },
            invitedEmails = input.invitedEmails,
            managerId = jwt.getAccountId(),
        )
        return toActivityDto(activity.id)
    }

    fun updateActivity(activityId: UUID, input: ActivityInput, jwt: Jwt): ActivityDto {
        val activity = activityRepo.getActivity(activityId)
        jwt.verifyAccountHasId(activity.manager.id)
        activityRepo.updateActivity(
            activityId = activityId,
            title = input.title,
            agenda = input.agenda,
            runMode = input.runMode,
            sendEmails = input.sendEmails,
            questions = input.questions.map {
                ActivityQuestionUpsert(
                    id = it.id,
                    questionText = it.questionText,
                    feedbackType = it.feedbackType,
                )
            },
            invitedEmails = input.invitedEmails,
        )
        return toActivityDto(activityId)
    }

    fun deleteActivity(activityId: UUID, jwt: Jwt) {
        val activity = activityRepo.getActivity(activityId)
        jwt.verifyAccountHasId(activity.manager.id)
        activityRepo.deleteActivity(activityId)
    }

    fun getManagerActivities(managerId: String): List<ActivityDto> {
        return activityRepo.getManagerActivities(managerId).map { activity ->
            activity.toActivityDto(
                events = eventRepo.getEventsForActivity(activity.id),
                pinCodeProvider = eventRepo::getPinCodeForEvent,
            )
        }
    }

    fun toActivityDto(activityId: UUID): ActivityDto {
        val activity = activityRepo.getActivity(activityId)
        return activity.toActivityDto(
            events = eventRepo.getEventsForActivity(activity.id),
            pinCodeProvider = eventRepo::getPinCodeForEvent,
        )
    }
}
