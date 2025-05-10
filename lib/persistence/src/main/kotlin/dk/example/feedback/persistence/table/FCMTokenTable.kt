package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object FCMTokenTable : CommonColumnsTbl("fcm_token") {
    val account = reference("account_id", AccountTable.id, onDelete = ReferenceOption.CASCADE)
    val value = varchar("value", 255)
}
