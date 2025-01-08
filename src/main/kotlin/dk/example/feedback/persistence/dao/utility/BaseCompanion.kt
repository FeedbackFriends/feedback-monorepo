package dk.example.feedback.persistence.dao.utility

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



