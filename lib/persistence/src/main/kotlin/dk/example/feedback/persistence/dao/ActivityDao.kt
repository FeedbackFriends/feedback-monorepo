package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.ActivityEntity
import dk.example.feedback.persistence.table.ActivityTable
import java.util.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class ActivityDao(id: EntityID<UUID>) : Entity<UUID>(id) {

    companion object : EntityClass<UUID, ActivityDao>(ActivityTable)

    var createdAt by ActivityTable.dateCreated
    var newFeedback by ActivityTable.newFeedback
    var seenByManager by ActivityTable.seenByManager
    var event by EventDao referencedOn ActivityTable.event
    var account by AccountDao referencedOn ActivityTable.account

    fun toModel(): ActivityEntity {
        return ActivityEntity(
            id = this.id.value,
            createdAt = this.createdAt,
            newFeedback = this.newFeedback,
            event = this.event.toModel(),
            account = this.account.toModel(),
            seenByManager = this.seenByManager
        )
    }
}
