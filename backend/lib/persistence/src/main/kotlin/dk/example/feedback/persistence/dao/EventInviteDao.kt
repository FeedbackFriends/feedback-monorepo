package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.ActivityInviteEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.ActivityInviteTable
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID

class ActivityInviteDao(id: EntityID<UUID>) : CommonColumns<ActivityInviteEntity>(id, ActivityInviteTable) {

    companion object : BaseCompanion<ActivityInviteEntity, ActivityInviteDao>(ActivityInviteTable)

    var activity by ActivityInviteTable.activity
    var email by ActivityInviteTable.email

    override fun toModel(): ActivityInviteEntity {
        return ActivityInviteEntity(
            id = id.value,
            email = email,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
        )
    }
}

typealias EventInviteDao = ActivityInviteDao
