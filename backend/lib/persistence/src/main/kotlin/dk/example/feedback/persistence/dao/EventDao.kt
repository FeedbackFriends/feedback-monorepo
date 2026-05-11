package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.QuestionTable
import dk.example.feedback.persistence.table.EventTable
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID

class EventDao(id: EntityID<UUID>): CommonColumns<EventEntity>(id, EventTable) {

    companion object : BaseCompanion<EventEntity, EventDao>(EventTable)

    var date by EventTable.startDate
    var durationInMinutes by EventTable.durationInMinutes
    var location by EventTable.location
    var createdFromMailListener by EventTable.createdFromMailListener
    var calendarProvider by EventTable.calendarProvider
    var calendarEventId by EventTable.calendarEventId
    var manager by AccountDao referencedOn EventTable.manager
    var activity by ActivityDao referencedOn EventTable.activity
    val questions by QuestionDao optionalReferrersOn QuestionTable.event

    override fun toModel(): EventEntity {
        return EventEntity(
            id = id.value,
            activity = activity.toModel(),
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
