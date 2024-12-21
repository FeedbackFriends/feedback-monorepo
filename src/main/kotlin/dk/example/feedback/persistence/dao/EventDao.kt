package dk.example.feedback.persistence.dao

import dk.example.feedback.model.db_models.EventEntity
import dk.example.feedback.persistence.table.*
import dk.example.feedback.persistence.table.AccountTable.default
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.*

class EventDao(id: EntityID<UUID>): UUIDEntity(id) {

    companion object : UUIDEntityClass<EventDao>(EventTable)

    var title by EventTable.title
    var agenda by EventTable.agenda
    var date by EventTable.date
    var durationInMinutes by EventTable.durationInMinutes
    var location by EventTable.location
    var pinCode by EventTable.pinCode
    var manager by AccountDao referencedOn EventTable.manager
    var createdAt by EventTable.createdAt.default(OffsetDateTime.now(ZoneOffset.UTC))
    var updatedAt by EventTable.updatedAt.default(OffsetDateTime.now(ZoneOffset.UTC))
    val questions by QuestionDao referrersOn QuestionTable.event
//    var team by TeamDao optionalReferencedOn EventTable.team
    var newFeedback by EventTable.newFeedback

    fun toModel(): EventEntity {
        return EventEntity(
            id = id.value,
            title = title,
            agenda = agenda,
            date = date,
            durationInMinutes = durationInMinutes,
            location = location,
            pinCode = pinCode,
            createdAt = createdAt,
            updatedAt = updatedAt,
            feedback = questions.flatMap { it.feedback }.map { it.toModel() },
            questions = questions.map { it.toModel() },
            newFeedback = newFeedback,
            manager = manager.toModel(),
        )
    }
}
