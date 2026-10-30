package dk.example.feedback.tests

import java.sql.DriverManager
import java.util.UUID
import liquibase.command.CommandScope
import liquibase.database.core.H2Database
import liquibase.database.jvm.JdbcConnection
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Test

class ActivityAgendaMigrationTest {
    @Test
    fun `agenda migration removes column while preserving activity`() {
        DriverManager.getConnection("jdbc:h2:mem:${UUID.randomUUID()};MODE=PostgreSQL;DATABASE_TO_UPPER=false").use { connection ->
            connection.createStatement().use { statement ->
                statement.execute("CREATE TABLE activity (id UUID PRIMARY KEY, title TEXT NOT NULL, agenda TEXT)")
                statement.execute("INSERT INTO activity VALUES (RANDOM_UUID(), 'Team meeting', 'Old agenda')")
            }
            val database = H2Database().apply { this.connection = JdbcConnection(connection) }
            CommandScope("update")
                .addArgumentValue("changelogFile", "db/changelog/0024-drop-activity-agenda.yaml")
                .addArgumentValue("database", database)
                .execute()

            connection.metaData.getColumns(null, null, "activity", "agenda").use { columns ->
                assertFalse(columns.next())
            }
            connection.createStatement().use { statement ->
                statement.executeQuery("SELECT title FROM activity").use { rows ->
                    rows.next()
                    assertEquals("Team meeting", rows.getString(1))
                    assertFalse(rows.next())
                }
            }
        }
    }
}
