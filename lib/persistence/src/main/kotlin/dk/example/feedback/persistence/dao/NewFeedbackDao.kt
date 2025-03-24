package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.NewFeedbackEntity
import dk.example.feedback.persistence.table.NewFeedbackTable
import java.util.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class NewFeedbackDao(id: EntityID<UUID>) : Entity<UUID>(id) {

    companion object : EntityClass<UUID, NewFeedbackDao>(NewFeedbackTable)

    var lastFeedbackReceived by NewFeedbackTable.lastFeedbackReceived
    var newFeedback by NewFeedbackTable.newFeedback
    var event by EventDao referencedOn NewFeedbackTable.id
    var account by AccountDao referencedOn NewFeedbackTable.account

    fun toModel(): NewFeedbackEntity {
        return NewFeedbackEntity(
            lastFeedbackReceived = this.lastFeedbackReceived,
            newFeedback = this.newFeedback,
            event = this.event.toModel(),
            account = this.account.toModel()
        )
    }
}
