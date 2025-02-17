package dk.example.feedback.persistence.dao.utility

import java.time.OffsetDateTime
import org.jetbrains.exposed.dao.EntityChangeType
import org.jetbrains.exposed.dao.EntityHook
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.toEntity

abstract class BaseCompanion<T, E : CommonColumns<T>>(table: CommonColumnsTbl) : UUIDEntityClass<E>(table) {
    init {
        EntityHook.subscribe { action ->
            if (action.changeType == EntityChangeType.Updated) {
                action.toEntity(this)?.lastUpdate = OffsetDateTime.now()
            }
        }
    }
}



