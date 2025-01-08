package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.PinCodeEntity
import dk.example.feedback.persistence.table.PinCodeTable
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID

class PinCodeDao(id: EntityID<UUID>): CommonColumns<PinCodeEntity>(id, PinCodeTable) {

    companion object : BaseCompanion<PinCodeEntity, PinCodeDao>(PinCodeTable)

    var pinCode by PinCodeTable.pinCode
    var event by EventDao referencedOn PinCodeTable.event
    

    override fun toModel(): PinCodeEntity {
        return PinCodeEntity(
            id = id.value,
            pinCode = pinCode,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
        )
    }
}
