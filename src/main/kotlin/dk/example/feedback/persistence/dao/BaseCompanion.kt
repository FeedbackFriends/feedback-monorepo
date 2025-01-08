package dk.example.feedback.persistence.dao

import java.time.OffsetDateTime
import java.util.*
import org.jetbrains.exposed.dao.EntityChangeType
import org.jetbrains.exposed.dao.EntityHook
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.dao.toEntity
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

abstract class BaseCompanion<T, E : CommonColumns<T>>(table: CommonColumnsTbl) : UUIDEntityClass<E>(table) {
    init {
        EntityHook.subscribe { action ->
            if (action.changeType == EntityChangeType.Updated) {
                action.toEntity(this)?.lastUpdate = OffsetDateTime.now()
            }
        }
    }
}
abstract class CommonColumnsTbl(name: String, idColumn: String = "${name}") : UUIDTable(name, idColumn) {
    val dateCreated = timestampWithTimeZone("date_created").clientDefault { OffsetDateTime.now() }
    val lastUpdated = timestampWithTimeZone("last_updated").clientDefault { OffsetDateTime.now() }
}

abstract class CommonColumns<T>(id: EntityID<UUID>, table: CommonColumnsTbl) : UUIDEntity(id) {
    val dateCreated by table.dateCreated
    var lastUpdate by table.lastUpdated

    abstract fun toModel(): T
}
