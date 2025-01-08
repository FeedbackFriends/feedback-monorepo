package dk.example.feedback.persistence.dao.utility

import java.time.OffsetDateTime
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

abstract class CommonColumnsTbl(name: String, idColumn: String = "${name}") : UUIDTable(name, idColumn) {
    val dateCreated = timestampWithTimeZone("date_created").clientDefault { OffsetDateTime.now() }
    val lastUpdated = timestampWithTimeZone("last_updated").clientDefault { OffsetDateTime.now() }
}
