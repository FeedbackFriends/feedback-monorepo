package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.ActivityEntity
import dk.example.feedback.model.enumerations.ActivityRunMode
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.helpers.normalizedEmail
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.ActivityDao
import dk.example.feedback.persistence.dao.ActivityInviteDao
import dk.example.feedback.persistence.dao.QuestionDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.ActivityInviteTable
import dk.example.feedback.persistence.table.ActivityTable
import dk.example.feedback.persistence.table.QuestionTable
import dk.example.feedback.persistence.table.EventParticipantTable
import dk.example.feedback.persistence.table.EventTable
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class ActivityRepo {

    private val logger = LoggerFactory.getLogger(ActivityRepo::class.java)

    fun persistActivity(
        title: String,
        agenda: String?,
        runMode: ActivityRunMode,
        sendEmails: Boolean,
        questions: List<ActivityQuestionUpsert>,
        invitedEmails: List<String>,
        managerId: String,
    ): ActivityEntity {
        val manager = AccountDao.findById(managerId) ?: throw IllegalArgumentException("Could not find manager id: $managerId")
        val activity = ActivityDao.new {
            this.title = title
            this.agenda = agenda
            this.runMode = runMode
            this.sendEmails = sendEmails
            this.manager = manager
        }
        replaceQuestions(activity.id.value, questions, managerId)
        replaceInvites(activity.id.value, managerId, invitedEmails)
        return activity.toModel()
    }

    fun updateActivity(
        activityId: UUID,
        title: String,
        agenda: String?,
        runMode: ActivityRunMode,
        sendEmails: Boolean,
        questions: List<ActivityQuestionUpsert>,
        invitedEmails: List<String>,
        managerId: String,
    ): ActivityEntity {
        val activity = ActivityDao.findById(activityId) ?: throw IllegalArgumentException("Could not find activity id: $activityId")
        if (activity.manager.id.value != managerId) {
            throw IllegalArgumentException("Activity $activityId does not belong to manager $managerId")
        }
        activity.apply {
            this.title = title
            this.agenda = agenda
            this.runMode = runMode
            this.sendEmails = sendEmails
        }
        replaceQuestions(activityId, questions, activity.manager.id.value)
        replaceInvites(activityId, activity.manager.id.value, invitedEmails)
        return activity.toModel()
    }

    fun deleteActivity(activityId: UUID, managerId: String) {
        val activity = ActivityDao.findById(activityId) ?: throw IllegalArgumentException("Could not find activity id: $activityId")
        if (activity.manager.id.value != managerId) {
            throw IllegalArgumentException("Activity $activityId does not belong to manager $managerId")
        }
        activity.delete()
    }

    fun getActivity(activityId: UUID): ActivityEntity {
        return ActivityDao.findById(activityId)?.toModel() ?: throw IllegalArgumentException("Could not find activity id: $activityId")
    }

    fun getManagerActivities(managerId: String): List<ActivityEntity> {
        return ActivityDao.find { ActivityTable.manager eq managerId }.map { it.toModel() }
    }
    fun createMailListenerActivity(
        managerId: String,
        title: String,
        agenda: String?,
        invitedEmails: List<String>,
    ): ActivityEntity {
        return persistActivity(
            title = title,
            agenda = agenda,
            runMode = ActivityRunMode.AUTOMATIC,
            sendEmails = false,
            questions = emptyList(),
            invitedEmails = invitedEmails,
            managerId = managerId,
        )
    }

    private fun replaceQuestions(activityId: UUID, questions: List<ActivityQuestionUpsert>, managerId: String) {
        val existingQuestions = QuestionDao
            .find { QuestionTable.activity eq activityId }
            .associateBy { it.id.value }

        questions
            .mapNotNull { it.id }
            .forEach { questionId ->
                if (!existingQuestions.containsKey(questionId)) {
                    throw IllegalArgumentException("Question $questionId does not belong to activity $activityId")
                }
            }

        val retainedQuestionIds = questions.mapNotNull { it.id }.toSet()
        existingQuestions
            .values
            .filterNot { retainedQuestionIds.contains(it.id.value) }
            .forEach { it.delete() }

        questions.forEachIndexed { index, questionInput ->
            val existingQuestion = questionInput.id?.let { existingQuestions[it] }
            if (existingQuestion != null) {
                existingQuestion.questionText = questionInput.questionText
                existingQuestion.feedbackType = questionInput.feedbackType
                existingQuestion.index = index
                existingQuestion.activityQuestionId = existingQuestion.activityQuestionId ?: existingQuestion.id.value
            } else {
                val questionId = UUID.randomUUID()
                QuestionDao.new(id = questionId) {
                    this.activity = ActivityDao[EntityID(activityId, ActivityTable)]
                    this.questionText = questionInput.questionText
                    this.feedbackType = questionInput.feedbackType
                    this.manager = AccountDao[managerId]
                    this.activityQuestionId = questionId
                    this.index = index
                }
            }
        }
    }

    private fun replaceInvites(activityId: UUID, managerId: String, invitedEmails: List<String>) {
        val cleanedEmails = invitedEmails
            .mapNotNull { it.normalizedEmail() }
            .filter { it.isNotBlank() }
            .distinct()

        val activityEntityId = EntityID(activityId, ActivityTable)
        val existingInvites = ActivityInviteDao.find { ActivityInviteTable.activity eq activityEntityId }.toList()
        existingInvites.filter { invite -> !cleanedEmails.contains(invite.email) }.forEach { it.delete() }

        val existingEmails = ActivityInviteDao.find { ActivityInviteTable.activity eq activityEntityId }.map { it.email }.toSet()
        cleanedEmails
            .filterNot { existingEmails.contains(it) }
            .forEach { email ->
                ActivityInviteDao.new {
                    this.activity = activityEntityId
                    this.email = email
                }
            }

        val accountsByEmail = lookupAccountsByEmail(cleanedEmails)
        EventDao.find { EventTable.activity eq activityId }.forEach { event ->
            accountsByEmail.values.forEach { account ->
                if (account.id.value == managerId) {
                    return@forEach
                }
                val alreadyJoined = EventParticipantTable.selectAll().where {
                    (EventParticipantTable.event eq event.id.value) and
                        (EventParticipantTable.participant eq account.id.value)
                }.singleOrNull()
                if (alreadyJoined == null) {
                    EventParticipantTable.insert {
                        it[EventParticipantTable.event] = EntityID(event.id.value, EventTable)
                        it[EventParticipantTable.participant] = account.id.value
                        it[EventParticipantTable.feedbackSubmitted] = false
                    }
                }
            }
        }
        logger.info("Activity invites synced activityId={} inviteCount={}", activityId, cleanedEmails.size)
    }

    private fun lookupAccountsByEmail(invitedEmails: List<String>): Map<String, AccountDao> {
        if (invitedEmails.isEmpty()) {
            return emptyMap()
        }
        return AccountDao
            .find { AccountTable.email inList invitedEmails }
            .mapNotNull { dao ->
                val email = dao.email ?: return@mapNotNull null
                email to dao
            }
            .toMap()
    }
}

data class ActivityQuestionUpsert(
    val id: UUID?,
    val questionText: String,
    val feedbackType: FeedbackType,
)
