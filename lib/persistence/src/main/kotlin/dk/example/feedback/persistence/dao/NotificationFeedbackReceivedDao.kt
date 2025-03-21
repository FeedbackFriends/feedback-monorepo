package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.NotificationFeedbackReceivedEntity
import dk.example.feedback.persistence.table.NotificationFeedbackReceivedTable
import java.util.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class NotificationFeedbackReceivedDao(id: EntityID<UUID>) : Entity<UUID>(id) {

    companion object : EntityClass<UUID, NotificationFeedbackReceivedDao>(NotificationFeedbackReceivedTable)

    var lastFeedbackReceived by NotificationFeedbackReceivedTable.lastFeedbackReceived
    var newFeedback by NotificationFeedbackReceivedTable.newFeedback
    var event by EventDao referencedOn NotificationFeedbackReceivedTable.id

    fun toModel(): NotificationFeedbackReceivedEntity {
        return NotificationFeedbackReceivedEntity(
            lastFeedbackReceived = this.lastFeedbackReceived,
            newFeedback = this.newFeedback,
            event = this.event.toModel(),
            account = this.event.manager.toModel()
        )
    }
}
