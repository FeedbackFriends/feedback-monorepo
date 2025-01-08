package dk.example.feedback.persistence.dao.utility

import java.util.*
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.id.EntityID

abstract class CommonColumns<T>(id: EntityID<UUID>, table: CommonColumnsTbl) : UUIDEntity(id) {
    val dateCreated by table.dateCreated
    var lastUpdate by table.lastUpdated

    abstract fun toModel(): T
}
