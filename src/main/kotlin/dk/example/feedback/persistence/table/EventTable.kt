package dk.example.feedback.persistence.table

import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

object EventTable: CommonColumnsTbl("event") {
    val title = varchar("title", 255)
    val agenda = varchar("agenda", 255).nullable()
    val date = timestampWithTimeZone("date")
    val durationInMinutes = integer("duration_in_minutes")
    val location = varchar("location", 255).nullable().default(null)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
}
