package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.SessionEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.QuestionTable
import dk.example.feedback.persistence.table.SessionTable
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID

class SessionDao(id: EntityID<UUID>): CommonColumns<SessionEntity>(id, SessionTable) {

    companion object : BaseCompanion<SessionEntity, SessionDao>(SessionTable)

    var title by SessionTable.title
    var agenda by SessionTable.agenda
    var date by SessionTable.startDate
    var durationInMinutes by SessionTable.durationInMinutes
    var location by SessionTable.location
    var createdFromMailListener by SessionTable.createdFromMailListener
    var calendarProvider by SessionTable.calendarProvider
    var calendarEventId by SessionTable.calendarEventId
    var manager by AccountDao referencedOn SessionTable.manager
    var activity by ActivityDao referencedOn SessionTable.activity
    val questions by QuestionDao optionalReferrersOn QuestionTable.session

    override fun toModel(): SessionEntity {
        return SessionEntity(
            id = id.value,
            activity = activity.toModel(),
            title = title,
            agenda = agenda,
            date = date,
            durationInMinutes = durationInMinutes,
            location = location,
            calendarProvider = calendarProvider,
            calendarEventId = calendarEventId,
            createdFromMailListener = createdFromMailListener,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
            feedback = questions.flatMap { it.feedback }.map { it.toModel() },
            questions = questions.map { it.toModel() },
            manager = manager.toModel(),
        )
    }
}

typealias EventDao = SessionDao
