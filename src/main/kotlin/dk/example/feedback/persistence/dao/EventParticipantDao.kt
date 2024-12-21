package dk.example.feedback.persistence.dao

import dk.example.feedback.model.db_models.EventParticipantEntity
import dk.example.feedback.persistence.table.EventParticipantTable
import dk.example.feedback.persistence.table.EventTable
import dk.example.feedback.persistence.table.FeedbackTable
import java.util.*
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID


//class FeedbackDao(id: EntityID<UUID>): UUIDEntity(id) {
//
//    companion object: UUIDEntityClass<FeedbackDao>(FeedbackTable)

class EventParticipantDao(id: EntityID<UUID>): UUIDEntity(id) {

    companion object : UUIDEntityClass<EventParticipantDao>(EventParticipantTable)

//class EventParticipantDao(id: EntityID<UUID>): CommonColumns<EventParticipantEntity>(id, EventParticipantTable) {
//
//    companion object : BaseCompanion<EventParticipantEntity, EventParticipantDao>(EventParticipantTable)

    var event by EventDao referencedOn EventParticipantTable.event
    var participant by AccountDao referencedOn EventParticipantTable.participant
    var feedback by FeedbackDao optionalReferencedOn  EventParticipantTable.feedback

    fun toModel(): EventParticipantEntity {
        return EventParticipantEntity(
            event = event.toModel(),
            participant = participant.toModel(),
            feedback = feedback?.toModel()
        )
    }
}

