package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.FCMTokenEntity
import dk.example.feedback.persistence.table.FCMTokenTable
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class FCMTokenDao(id: EntityID<String>) : Entity<String>(id) {

    companion object : EntityClass<String, FCMTokenDao>(FCMTokenTable)

    var value by FCMTokenTable.id
    var account by AccountDao referencedOn FCMTokenTable.account

    fun toModel(): FCMTokenEntity {
        return FCMTokenEntity(
            value = this.id.value,
        )
    }
}
