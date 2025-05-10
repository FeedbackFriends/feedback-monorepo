package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.FCMTokenEntity
import dk.example.feedback.persistence.table.FCMTokenTable
import java.util.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class FCMTokenDao(id: EntityID<UUID>) : Entity<UUID>(id) {

    companion object : EntityClass<UUID, FCMTokenDao>(FCMTokenTable)

    var createdAt by FCMTokenTable.dateCreated
    var value by FCMTokenTable.value
    var account by AccountDao referencedOn FCMTokenTable.account

    fun toModel(): FCMTokenEntity {
        return FCMTokenEntity(
            id = this.id.value,
            createdAt = this.createdAt,
            value = this.value,
        )
    }
}
