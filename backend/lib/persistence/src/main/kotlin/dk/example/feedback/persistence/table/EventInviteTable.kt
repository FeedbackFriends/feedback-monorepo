package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object ActivityInviteTable : CommonColumnsTbl("activity_invite") {
    val activity = reference("activity_id", ActivityTable.id, onDelete = ReferenceOption.CASCADE)
    val event = activity
    val email = varchar("email", 255)

    init {
        uniqueIndex("uk_activity_invite_activity_email", activity, email)
    }
}

typealias EventInviteTable = ActivityInviteTable
