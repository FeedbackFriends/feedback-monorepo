package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.EventInviteEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.EventInviteTable
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID

class EventInviteDao(id: EntityID<UUID>) : CommonColumns<EventInviteEntity>(id, EventInviteTable) {

    companion object : BaseCompanion<EventInviteEntity, EventInviteDao>(EventInviteTable)

    var event by EventInviteTable.event
    var email by EventInviteTable.email
    var account by AccountDao optionalReferencedOn EventInviteTable.account

    override fun toModel(): EventInviteEntity {
        return EventInviteEntity(
            id = id.value,
            email = email,
            accountId = account?.id?.value,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
        )
    }
}
