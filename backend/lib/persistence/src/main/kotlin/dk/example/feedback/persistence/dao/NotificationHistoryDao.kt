package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.NotificationHistoryEntity
import dk.example.feedback.persistence.table.NotificationHistoryTable
import java.util.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class NotificationHistoryDao(id: EntityID<UUID>) : Entity<UUID>(id) {

    companion object : EntityClass<UUID, NotificationHistoryDao>(NotificationHistoryTable)

    var createdAt by NotificationHistoryTable.dateCreated
    var newFeedback by NotificationHistoryTable.newFeedback
    var seenByManager by NotificationHistoryTable.seenByManager
    var session by SessionDao referencedOn NotificationHistoryTable.session
    var event by SessionDao referencedOn NotificationHistoryTable.event
    var account by AccountDao referencedOn NotificationHistoryTable.account

    fun toModel(): NotificationHistoryEntity {
        return NotificationHistoryEntity(
            id = this.id.value,
            createdAt = this.createdAt,
            newFeedback = this.newFeedback,
            session = this.session.toModel(),
            account = this.account.toModel(),
            seenByManager = this.seenByManager,
        )
    }
}
