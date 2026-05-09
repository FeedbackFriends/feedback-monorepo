package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.database.QuestionEntity
import dk.example.feedback.model.database.SessionEntity
import dk.example.feedback.model.enumerations.CalendarProvider
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.exceptions.PinCodeNotFoundException
import dk.example.feedback.model.helpers.normalizedEmail
import dk.example.feedback.persistence.dao.AccountDao
import dk.example.feedback.persistence.dao.ActivityDao
import dk.example.feedback.persistence.dao.ActivityInviteDao
import dk.example.feedback.persistence.dao.PinCodeDao
import dk.example.feedback.persistence.dao.QuestionDao
import dk.example.feedback.persistence.dao.SessionDao
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.persistence.table.ActivityInviteTable
import dk.example.feedback.persistence.table.QuestionTable
import dk.example.feedback.persistence.table.SessionParticipantTable
import dk.example.feedback.persistence.table.SessionTable
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
class SessionRepo {

    private val logger = LoggerFactory.getLogger(SessionRepo::class.java)

    fun cleanUpPinCodesWithStopTimeOlderThan(duration: Duration) {
        val now = OffsetDateTime.now(ZoneOffset.UTC)
        SessionDao.all().forEach { sessionDao ->
            val sessionStopTime = sessionDao.date.plusMinutes(sessionDao.durationInMinutes.toLong())
            val durationFromStartToStop = Duration.between(sessionStopTime, now)
            if (sessionStopTime.isBefore(now) && durationFromStartToStop > duration) {
                sessionDao.questions.forEach { question ->
                    question.feedback.forEach { it.delete() }
                    question.delete()
                }
                PinCodeDao.findById(getPinCodeForSession(sessionDao.id.value) ?: return@forEach)?.delete()
            }
        }
    }

    fun pinCodeExists(pinCode: String): Boolean {
        return PinCodeDao.findById(pinCode) != null
    }

    fun persistSession(
        activityId: UUID,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        generatedPinCode: String,
        managerId: String,
        createdFromMailListener: Boolean = false,
        calendarProvider: CalendarProvider? = null,
        calendarEventId: String? = null,
    ): SessionEntity {
        val activity = ActivityDao.findById(activityId) ?: throw IllegalArgumentException("Could not find activity id: $activityId")
        if (activity.manager.id.value != managerId) {
            throw IllegalArgumentException("Activity $activityId does not belong to manager $managerId")
        }
        val manager = AccountDao.findById(managerId) ?: throw IllegalArgumentException("Could not find manager id: $managerId")
        val createdSession = SessionDao.new {
            this.activity = activity
            this.title = activity.title
            this.agenda = activity.agenda
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
            this.manager = manager
            this.createdFromMailListener = createdFromMailListener
            this.calendarProvider = calendarProvider
            this.calendarEventId = calendarEventId
        }
        PinCodeDao.new(id = generatedPinCode) {
            this.session = createdSession
        }
        snapshotQuestionsFromActivity(
            sessionId = createdSession.id.value,
            activityId = activityId,
            managerId = managerId,
        )
        joinParticipantsFromActivityInvites(
            sessionId = createdSession.id.value,
            activityId = activityId,
            managerId = managerId,
        )
        return createdSession.toModel()
    }

    fun getSessionByCalendarEventId(managerId: String, calendarEventId: String): SessionEntity? {
        return SessionDao
            .find { (SessionTable.manager eq managerId) and (SessionTable.calendarEventId eq calendarEventId) }
            .firstOrNull()
            ?.toModel()
    }

    fun updateSessionFromMailListener(
        sessionId: UUID,
        title: String,
        agenda: String?,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
        invitedEmails: List<String>,
        calendarProvider: CalendarProvider?,
        calendarEventId: String?,
    ): SessionEntity {
        val foundSession = SessionDao.findById(sessionId) ?: throw IllegalArgumentException("Could not find session id: $sessionId")
        foundSession.apply {
            this.title = title
            this.agenda = agenda
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
            this.calendarProvider = calendarProvider
            this.calendarEventId = calendarEventId
            this.createdFromMailListener = true
        }

        val activity = foundSession.activity
        activity.title = title
        activity.agenda = agenda
        replaceActivityInvites(activity.id.value, activity.manager.id.value, invitedEmails)

        return foundSession.toModel()
    }

    fun deleteSession(sessionId: UUID) {
        val foundSession = SessionDao.findById(sessionId) ?: throw IllegalArgumentException("Could not find session id: $sessionId")
        foundSession.delete()
    }

    fun updateSession(
        sessionId: UUID,
        date: OffsetDateTime,
        location: String?,
        durationInMinutes: Int,
    ): SessionEntity {
        val foundSession = SessionDao.findById(sessionId) ?: throw IllegalArgumentException("Could not find session id: $sessionId")
        foundSession.apply {
            this.date = date
            this.location = location
            this.durationInMinutes = durationInMinutes
        }
        return foundSession.toModel()
    }

    fun getSessionByPinCode(pinCode: String): SessionEntity {
        return PinCodeDao.findById(pinCode)?.session?.toModel() ?: throw PinCodeNotFoundException(pinCode = pinCode)
    }

    fun getSession(sessionId: UUID): SessionEntity {
        return SessionDao.findById(sessionId)?.toModel() ?: throw IllegalArgumentException("Could not find session id: $sessionId")
    }

    fun getManagerSessions(managerId: String): List<SessionEntity> {
        return SessionDao.find { SessionTable.manager eq managerId }.map { it.toModel() }
    }

    fun getSessionsForActivity(activityId: UUID): List<SessionEntity> {
        return SessionDao.find { SessionTable.activity eq activityId }.map { it.toModel() }
    }

    fun getSessionsForActivityStartingAtOrAfter(activityId: UUID, fromDate: OffsetDateTime): List<SessionEntity> {
        return SessionDao
            .find { (SessionTable.activity eq activityId) and (SessionTable.startDate greaterEq fromDate) }
            .map { it.toModel() }
    }

    fun getParticipantsForSession(sessionId: UUID, managerId: String): List<AccountEntity> {
        val participantIds = SessionParticipantTable
            .selectAll()
            .where { SessionParticipantTable.session eq sessionId }
            .map { it[SessionParticipantTable.participant].value }
            .filterNot { it == managerId }

        if (participantIds.isEmpty()) {
            return emptyList()
        }

        val accountsById = AccountDao
            .find { AccountTable.id inList participantIds }
            .associateBy { it.id.value }

        return participantIds.mapNotNull { accountsById[it]?.toModel() }
    }

    fun isParticipant(sessionId: UUID, accountId: String): Boolean {
        return SessionParticipantTable
            .selectAll()
            .where { (SessionParticipantTable.session eq sessionId) and (SessionParticipantTable.participant eq accountId) }
            .limit(1)
            .firstOrNull() != null
    }

    fun joinInvitedSessionsForEmail(accountId: String, email: String) {
        val normalizedEmail = email.normalizedEmail() ?: return
        val activityIds = ActivityInviteTable
            .selectAll()
            .where { ActivityInviteTable.email eq normalizedEmail }
            .map { it[ActivityInviteTable.activity].value }
            .distinct()

        if (activityIds.isEmpty()) {
            return
        }

        SessionDao
            .find { SessionTable.activity inList activityIds }
            .forEach { session ->
                if (session.manager.id.value != accountId) {
                    updateOrCreateParticipant(
                        sessionId = session.id.value,
                        accountId = accountId,
                        feedbackSubmitted = false,
                    )
                }
            }
    }

    data class ParticipantSessionsWithRecentlyJoined(
        val session: SessionEntity,
        val recentlyJoined: Boolean,
    ) {
        val event: SessionEntity
            get() = session
    }

    fun getParticipantSessions(participantId: String): List<ParticipantSessionsWithRecentlyJoined> {
        return SessionParticipantTable
            .selectAll()
            .where { SessionParticipantTable.participant eq participantId }
            .map { row ->
                val recentlyJoined = if (!row[SessionParticipantTable.feedbackSubmitted]) {
                    val oneHourAgo = Instant.now().minus(1, ChronoUnit.HOURS)
                    row[SessionParticipantTable.dateCreated].toInstant().isAfter(oneHourAgo)
                } else {
                    false
                }
                ParticipantSessionsWithRecentlyJoined(
                    session = getSession(row[SessionParticipantTable.session].value),
                    recentlyJoined = recentlyJoined,
                )
            }
    }

    fun accountDidSubmitFeedbackForSession(sessionId: UUID, accountId: String): Boolean {
        return SessionParticipantTable
            .selectAll()
            .where { (SessionParticipantTable.session eq sessionId) and (SessionParticipantTable.participant eq accountId) }
            .singleOrNull()
            ?.get(SessionParticipantTable.feedbackSubmitted)
            ?: false
    }

    fun updateOrCreateParticipant(sessionId: UUID, accountId: String, feedbackSubmitted: Boolean) {
        val existingRow = SessionParticipantTable
            .selectAll()
            .where { (SessionParticipantTable.session eq sessionId) and (SessionParticipantTable.participant eq accountId) }
            .singleOrNull()
        if (existingRow == null) {
            SessionParticipantTable.insert {
                it[session] = sessionId
                it[participant] = accountId
                it[SessionParticipantTable.feedbackSubmitted] = feedbackSubmitted
            }
        } else {
            SessionParticipantTable.update(
                { (SessionParticipantTable.session eq sessionId) and (SessionParticipantTable.participant eq accountId) }
            ) {
                it[SessionParticipantTable.feedbackSubmitted] = feedbackSubmitted
            }
        }
    }

    fun markSessionAsSeen(sessionId: UUID) {
        SessionDao.findById(sessionId)?.questions?.forEach { question ->
            question.feedback.forEach { feedback ->
                feedback.seenByManager = true
                feedback.flush()
            }
        }
    }

    fun getPinCodeForSession(sessionId: UUID): String? {
        return PinCodeDao.find { dk.example.feedback.persistence.table.PinCodeTable.session eq sessionId }
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
        sessionId: UUID,
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
            this[QuestionTable.session] = EntityID(sessionId, SessionTable)
            this[QuestionTable.activityQuestionId] = question.activityQuestionId ?: question.id.value
            this[QuestionTable.index] = question.index
        }
    }

    private fun joinParticipantsFromActivityInvites(
        sessionId: UUID,
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
                sessionId = sessionId,
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
        SessionDao.find { SessionTable.activity eq activityId }.forEach { session ->
            accountsByEmail.values.forEach { account ->
                if (account.id.value != managerId) {
                    updateOrCreateParticipant(
                        sessionId = session.id.value,
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
    ): SessionEntity {
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
        return persistSession(
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

    fun getEventByCalendarEventId(managerId: String, calendarEventId: String): SessionEntity? {
        return getSessionByCalendarEventId(managerId, calendarEventId)
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
    ): SessionEntity {
        return updateSessionFromMailListener(
            sessionId = eventId,
            title = title,
            agenda = agenda,
            date = date,
            location = location,
            durationInMinutes = durationInMinutes,
            invitedEmails = invitedEmails,
            calendarProvider = calendarProvider,
            calendarEventId = calendarEventId,
        )
    }

    fun deleteEvent(eventId: UUID) = deleteSession(eventId)

    fun getEvent(eventId: UUID): SessionEntity = getSession(eventId)

    fun getEventByPinCode(pinCode: String): SessionEntity = getSessionByPinCode(pinCode)

    fun getParticipantEvents(participantId: String): List<ParticipantSessionsWithRecentlyJoined> {
        return getParticipantSessions(participantId)
    }

    fun accountDidSubmitFeedbackForEvent(eventId: UUID, accountId: String): Boolean {
        return accountDidSubmitFeedbackForSession(eventId, accountId)
    }

    fun markEventAsSeen(eventId: UUID) = markSessionAsSeen(eventId)

    fun getPinCodeForEvent(eventId: UUID): String? = getPinCodeForSession(eventId)

    fun joinInvitedEventsForEmail(accountId: String, email: String) {
        joinInvitedSessionsForEmail(accountId, email)
    }
}

typealias EventRepo = SessionRepo
