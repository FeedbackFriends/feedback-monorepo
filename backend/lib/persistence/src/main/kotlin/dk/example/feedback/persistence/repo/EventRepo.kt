package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.database.QuestionEntity
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.exceptions.PinCodeNotFoundException
import dk.example.feedback.model.helpers.normalizedEmail
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.ActivityDao
import dk.example.feedback.persistence.dao.ActivityInviteDao
import dk.example.feedback.persistence.dao.PinCodeDao
import dk.example.feedback.persistence.dao.QuestionDao
import dk.example.feedback.persistence.dao.EventDao
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.ActivityInviteTable
import dk.example.feedback.persistence.table.QuestionTable
import dk.example.feedback.persistence.table.EventParticipantTable
import dk.example.feedback.persistence.table.EventTable
import java.time.Duration
import java.time.Instant
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.time.temporal.ChronoUnit
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.greaterEq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class EventRepo {

    private val logger = LoggerFactory.getLogger(EventRepo::class.java)

    fun cleanUpPinCodesWithStopTimeOlderThan(duration: Duration) {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        EventDao.all().forEach { eventDao ->
            val eventStopTime = eventDao.date.plusMinutes(eventDao.durationInMinutes.toLong())
            val durationFromStartToStop = Duration.between(eventStopTime, now)
            if (eventStopTime.isBefore(now) && durationFromStartToStop > duration) {
                PinCodeDao.findById(getPinCodeForEvent(eventDao.id.value) ?: return@forEach)?.delete()
            }
        }
    }

    fun pinCodeExists(pinCode: String): Boolean {
        return PinCodeDao.findById(pinCode) != null
    }

    fun persistEvent(
        activityId: UUID,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        generatedPinCode: String,
        managerId: String,
        createdFromMailListener: Boolean = false,
        calendarProvider: CalendarProvider? = null,
        calendarEventId: String? = null,
    ): EventEntity {
        val activity = ActivityDao.findById(activityId) ?: throw IllegalArgumentException("Could not find activity id: $activityId")
        if (activity.manager.id.value != managerId) {
            throw IllegalArgumentException("Activity $activityId does not belong to manager $managerId")
        }
        val manager = AccountDao.findById(managerId) ?: throw IllegalArgumentException("Could not find manager id: $managerId")
        val createdEvent = EventDao.new {
            this.activity = activity
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
            this.manager = manager
            this.createdFromMailListener = createdFromMailListener
            this.calendarProvider = calendarProvider
            this.calendarEventId = calendarEventId
        }
        PinCodeDao.new(id = generatedPinCode) {
            this.event = createdEvent
        }
        snapshotQuestionsFromActivity(
            eventId = createdEvent.id.value,
            activityId = activityId,
            managerId = managerId,
        )
        joinParticipantsFromActivityInvites(
            eventId = createdEvent.id.value,
            activityId = activityId,
            managerId = managerId,
        )
        return createdEvent.toModel()
    }

    fun getEventByCalendarEventId(managerId: String, calendarEventId: String): EventEntity? {
        return EventDao
            .find { (EventTable.manager eq managerId) and (EventTable.calendarEventId eq calendarEventId) }
            .firstOrNull()
            ?.toModel()
    }

    fun updateEventFromMailListener(
        eventId: UUID,
        title: String,
        agenda: String?,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        invitedEmails: List<String>,
        calendarProvider: CalendarProvider?,
        calendarEventId: String?,
    ): EventEntity {
        val foundEvent = EventDao.findById(eventId) ?: throw IllegalArgumentException("Could not find event id: $eventId")
        foundEvent.apply {
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
            this.calendarProvider = calendarProvider
            this.calendarEventId = calendarEventId
            this.createdFromMailListener = true
        }

        val activity = foundEvent.activity
        activity.title = title
        activity.agenda = agenda
        replaceActivityInvites(activity.id.value, activity.manager.id.value, invitedEmails)

        return foundEvent.toModel()
    }

    fun deleteEvent(eventId: UUID) {
        val foundEvent = EventDao.findById(eventId) ?: throw IllegalArgumentException("Could not find event id: $eventId")
        foundEvent.delete()
    }

    fun updateEvent(
        eventId: UUID,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
    ): EventEntity {
        val foundEvent = EventDao.findById(eventId) ?: throw IllegalArgumentException("Could not find event id: $eventId")
        foundEvent.apply {
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
        }
        return foundEvent.toModel()
    }

    fun getEventByPinCode(pinCode: String): EventEntity {
        return PinCodeDao.findById(pinCode)?.event?.toModel() ?: throw PinCodeNotFoundException(pinCode = pinCode)
    }

    fun getEvent(eventId: UUID): EventEntity {
        return EventDao.findById(eventId)?.toModel() ?: throw IllegalArgumentException("Could not find event id: $eventId")
    }

    fun getManagerEvents(managerId: String): List<EventEntity> {
        return EventDao.find { EventTable.manager eq managerId }.map { it.toModel() }
    }

    fun getEventsForActivity(activityId: UUID): List<EventEntity> {
        return EventDao.find { EventTable.activity eq activityId }.map { it.toModel() }
    }

    fun getEventsForActivityStartingAtOrAfter(activityId: UUID, fromDate: OffsetDateTime): List<EventEntity> {
        return EventDao
            .find { (EventTable.activity eq activityId) and (EventTable.startDate greaterEq fromDate) }
            .map { it.toModel() }
    }

    fun getParticipantsForEvent(eventId: UUID, managerId: String): List<AccountEntity> {
        val participantIds = EventParticipantTable
            .selectAll()
            .where { EventParticipantTable.event eq eventId }
            .map { it[EventParticipantTable.participant].value }
            .filterNot { it == managerId }

        if (participantIds.isEmpty()) {
            return emptyList()
        }

        val accountsById = AccountDao
            .find { AccountTable.id inList participantIds }
            .associateBy { it.id.value }

        return participantIds.mapNotNull { accountsById[it]?.toModel() }
    }

    fun isParticipant(eventId: UUID, accountId: String): Boolean {
        return EventParticipantTable
            .selectAll()
            .where { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            .limit(1)
            .firstOrNull() != null
    }

    fun joinInvitedEventsForEmail(accountId: String, email: String) {
        val normalizedEmail = email.normalizedEmail() ?: return
        val activityIds = ActivityInviteTable
            .selectAll()
            .where { ActivityInviteTable.email eq normalizedEmail }
            .map { it[ActivityInviteTable.activity].value }
            .distinct()

        if (activityIds.isEmpty()) {
            return
        }

        EventDao
            .find { EventTable.activity inList activityIds }
            .forEach { event ->
                if (event.manager.id.value != accountId) {
                    updateOrCreateParticipant(
                        eventId = event.id.value,
                        accountId = accountId,
                        feedbackSubmitted = false,
                    )
                }
            }
    }

    data class ParticipantEventsWithRecentlyJoined(
        val event: EventEntity,
        val recentlyJoined: Boolean,
    )

    fun getParticipantEvents(participantId: String): List<ParticipantEventsWithRecentlyJoined> {
        return EventParticipantTable
            .selectAll()
            .where { EventParticipantTable.participant eq participantId }
            .map { row ->
                val recentlyJoined = if (!row[EventParticipantTable.feedbackSubmitted]) {
                    val oneHourAgo = Instant.now().minus(1, ChronoUnit.HOURS)
                    row[EventParticipantTable.dateCreated].toInstant().isAfter(oneHourAgo)
                } else {
                    false
                }
                ParticipantEventsWithRecentlyJoined(
                    event = getEvent(row[EventParticipantTable.event].value),
                    recentlyJoined = recentlyJoined,
                )
            }
    }

    fun accountDidSubmitFeedbackForEvent(eventId: UUID, accountId: String): Boolean {
        return EventParticipantTable
            .selectAll()
            .where { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            .singleOrNull()
            ?.get(EventParticipantTable.feedbackSubmitted)
            ?: false
    }

    fun updateOrCreateParticipant(eventId: UUID, accountId: String, feedbackSubmitted: Boolean) {
        val existingRow = EventParticipantTable
            .selectAll()
            .where { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            .singleOrNull()
        if (existingRow == null) {
            EventParticipantTable.insert {
                it[EventParticipantTable.event] = eventId
                it[EventParticipantTable.participant] = accountId
                it[EventParticipantTable.feedbackSubmitted] = feedbackSubmitted
            }
        } else {
            EventParticipantTable.update(
                { (EventParticipantTable.event eq eventId) and (EventParticipantTable.participant eq accountId) }
            ) {
                it[EventParticipantTable.feedbackSubmitted] = feedbackSubmitted
            }
        }
    }

    fun markEventAsSeen(eventId: UUID) {
        EventDao.findById(eventId)?.questions?.forEach { question ->
            question.feedback.forEach { feedback ->
                feedback.seenByManager = true
                feedback.flush()
            }
        }
    }

    fun getPinCodeForEvent(eventId: UUID): String? {
        return PinCodeDao.find { dk.example.feedback.persistence.table.PinCodeTable.event eq eventId }
            .firstOrNull()
            ?.pinCode
            ?.value
    }

    fun getRecentlyUsedQuestions(accountId: String): List<QuestionEntity> {
        return QuestionDao
            .all()
            .filter { it.manager.id.value == accountId && it.activity != null }
            .sortedByDescending { it.dateCreated }
            .map { it.toModel() }
            .distinctBy { it.questionText }
    }

    private fun snapshotQuestionsFromActivity(
        eventId: UUID,
        activityId: UUID,
        managerId: String,
    ) {
        val activityQuestions = QuestionDao
            .find { QuestionTable.activity eq activityId }
            .sortedBy { it.index }

        QuestionTable.batchInsert(activityQuestions) { question ->
            this[QuestionTable.questionText] = question.questionText
            this[QuestionTable.feedbackType] = question.feedbackType
            this[QuestionTable.manager] = managerId
            this[QuestionTable.event] = EntityID(eventId, EventTable)
            this[QuestionTable.activityQuestionId] = question.activityQuestionId ?: question.id.value
            this[QuestionTable.index] = question.index
        }
    }

    private fun joinParticipantsFromActivityInvites(
        eventId: UUID,
        activityId: UUID,
        managerId: String,
    ) {
        val invitedEmails = ActivityInviteDao
            .find { ActivityInviteTable.activity eq activityId }
            .map { it.email }
        val accountsByEmail = lookupAccountsByEmail(invitedEmails)
        accountsByEmail.values.forEach { account ->
            if (account.id.value == managerId) {
                return@forEach
            }
            updateOrCreateParticipant(
                eventId = eventId,
                accountId = account.id.value,
                feedbackSubmitted = false,
            )
        }
    }

    private fun replaceActivityInvites(activityId: UUID, managerId: String, invitedEmails: List<String>) {
        val cleanedEmails = cleanInvitedEmails(invitedEmails)
        val activityEntityId = EntityID(activityId, dk.example.feedback.persistence.table.ActivityTable)
        val existingInvites = ActivityInviteDao.find { ActivityInviteTable.activity eq activityEntityId }.toList()

        val cleanedSet = cleanedEmails.toSet()
        existingInvites
            .filter { invite -> !cleanedSet.contains(invite.email) }
            .forEach { it.delete() }

        val existingInviteEmails = ActivityInviteDao
            .find { ActivityInviteTable.activity eq activityEntityId }
            .map { it.email }
            .toSet()

        cleanedEmails
            .filterNot { existingInviteEmails.contains(it) }
            .forEach { email ->
                ActivityInviteDao.new {
                    this.activity = activityEntityId
                    this.email = email
                }
            }

        val accountsByEmail = lookupAccountsByEmail(cleanedEmails)
        EventDao.find { EventTable.activity eq activityId }.forEach { event ->
            accountsByEmail.values.forEach { account ->
                if (account.id.value != managerId) {
                    updateOrCreateParticipant(
                        eventId = event.id.value,
                        accountId = account.id.value,
                        feedbackSubmitted = false,
                    )
                }
            }
        }
    }

    private fun cleanInvitedEmails(invitedEmails: List<String>): List<String> {
        return invitedEmails
            .mapNotNull { it.normalizedEmail() }
            .filter { it.isNotEmpty() }
            .distinct()
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

    fun persistEvent(
        title: String,
        agenda: String?,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        generatedPinCode: String,
        questions: List<Pair<String, FeedbackType>>,
        managerId: String,
        createdFromMailListener: Boolean = false,
        invitedEmails: List<String> = emptyList(),
        calendarProvider: CalendarProvider? = null,
        calendarEventId: String? = null,
    ): EventEntity {
        val activity = ActivityRepo().persistActivity(
            title = title,
            agenda = agenda,
            runMode = dk.example.feedback.model.enumerations.ActivityRunMode.MANUAL,
            sendEmails = false,
            questions = questions.map { (questionText, feedbackType) ->
                ActivityQuestionUpsert(
                    id = null,
                    questionText = questionText,
                    feedbackType = feedbackType,
                )
            },
            invitedEmails = invitedEmails,
            managerId = managerId,
        )
        return persistEvent(
            activityId = activity.id,
            date = date,
            location = location,
            durationInMinutes = durationInMinutes,
            generatedPinCode = generatedPinCode,
            managerId = managerId,
            createdFromMailListener = createdFromMailListener,
            calendarProvider = calendarProvider,
            calendarEventId = calendarEventId,
        )
    }

}
