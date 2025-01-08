package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object PinCodeTable: CommonColumnsTbl("pin_code") {
    val pinCode = varchar("pin_code", 255)
    val event = reference("event_id", EventTable, onDelete = ReferenceOption.CASCADE)
}
