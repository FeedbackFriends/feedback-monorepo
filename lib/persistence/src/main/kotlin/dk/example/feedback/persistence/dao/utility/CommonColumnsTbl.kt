package dk.example.feedback.persistence.dao.utility

import java.time.OffsetDateTime
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.javatime.timestampWithTimeZone

abstract class CommonColumnsTbl(name: String, idColumn: String = "id") : UUIDTable(name, idColumn) {
    val dateCreated = timestampWithTimeZone("created_at").clientDefault { OffsetDateTime.now() }
    val lastUpdated = timestampWithTimeZone("updated_at").clientDefault { OffsetDateTime.now() }
}

//abstract class CommonColumnsTbl2(name: String, idColumn: String = "id", table: Table)<T: Table> : T {
//    val dateCreated = timestampWithTimeZone("created_at").clientDefault { OffsetDateTime.now() }
//    val lastUpdated = timestampWithTimeZone("updated_at").clientDefault { OffsetDateTime.now() }
//}
