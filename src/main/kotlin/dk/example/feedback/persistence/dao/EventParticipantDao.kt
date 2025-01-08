package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.EventParticipantEntity
import dk.example.feedback.persistence.table.EventParticipantTable
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID

class EventParticipantDao(id: EntityID<UUID>): CommonColumns<EventParticipantEntity>(id, EventParticipantTable) {

    companion object : BaseCompanion<EventParticipantEntity, EventParticipantDao>(EventParticipantTable)

    var event by EventDao referencedOn EventParticipantTable.event
    var participant by AccountDao referencedOn EventParticipantTable.participant
    var feedback by FeedbackDao optionalReferencedOn  EventParticipantTable.feedback

    override fun toModel(): EventParticipantEntity {
        return EventParticipantEntity(
            event = event.toModel(),
            participant = participant.toModel(),
            feedback = feedback?.toModel()
        )
    }
}
