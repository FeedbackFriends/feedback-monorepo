package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object EventInviteTable : CommonColumnsTbl("event_invite") {
    val event = reference("event_id", EventTable.id, onDelete = ReferenceOption.CASCADE)
    val email = varchar("email", 255)

    init {
        uniqueIndex("uk_event_invite_event_email", event, email)
    }
}
