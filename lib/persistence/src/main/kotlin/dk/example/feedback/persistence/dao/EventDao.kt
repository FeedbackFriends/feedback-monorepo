package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.QuestionTable
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID

class EventDao(id: EntityID<UUID>): CommonColumns<EventEntity>(id, EventTable) {

    companion object : BaseCompanion<EventEntity, EventDao>(EventTable)

    var title by EventTable.title
    var agenda by EventTable.agenda
    var date by EventTable.startDate
    var durationInMinutes by EventTable.durationInMinutes
    var location by EventTable.location
    var manager by AccountDao referencedOn EventTable.manager
    val questions by QuestionDao optionalReferrersOn QuestionTable.event

    override fun toModel(): EventEntity {
        return EventEntity(
            id = id.value,
            title = title,
            agenda = agenda,
            date = date,
            durationInMinutes = durationInMinutes,
            location = location,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
            feedback = questions.flatMap { it.feedback }.map { it.toModel() },
            questions = questions.map { it.toModel() },
            manager = manager.toModel(),
        )
    }
}


