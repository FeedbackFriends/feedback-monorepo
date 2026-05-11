package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.PinCodeEntity
import dk.example.feedback.persistence.table.PinCodeTable
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID

class PinCodeDao(id: EntityID<String>) : Entity<String>(id) {

    companion object : EntityClass<String, PinCodeDao>(PinCodeTable)

    var pinCode by PinCodeTable.id
    var event by EventDao referencedOn PinCodeTable.event

    fun toModel(): PinCodeEntity {
        return PinCodeEntity(
            pinCode = pinCode.value,
            event = event.toModel()
        )
    }
}
