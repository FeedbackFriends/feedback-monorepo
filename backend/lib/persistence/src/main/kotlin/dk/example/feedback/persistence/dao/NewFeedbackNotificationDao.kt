package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.NewFeedbackNotificationEntity
import dk.example.feedback.persistence.table.NewFeedbackNotificationTable
import java.util.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class NewFeedbackNotificationDao(id: EntityID<UUID>) : Entity<UUID>(id) {

    companion object : EntityClass<UUID, NewFeedbackNotificationDao>(NewFeedbackNotificationTable)

    var lastFeedbackAt by NewFeedbackNotificationTable.lastFeedbackAt
    var newFeedback by NewFeedbackNotificationTable.newFeedback
    var event by EventDao referencedOn NewFeedbackNotificationTable.event
    var account by AccountDao referencedOn NewFeedbackNotificationTable.account

    fun toModel(): NewFeedbackNotificationEntity {
        return NewFeedbackNotificationEntity(
            lastFeedbackAt = this.lastFeedbackAt,
            newFeedback = this.newFeedback,
            event = this.event.toModel(),
            account = this.account.toModel()
        )
    }
}
