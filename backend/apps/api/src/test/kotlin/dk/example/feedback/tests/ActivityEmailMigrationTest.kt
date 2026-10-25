package dk.example.feedback.tests

import java.sql.DriverManager
import java.sql.SQLException
import java.util.UUID
import liquibase.command.CommandScope
import liquibase.database.core.H2Database
import liquibase.database.jvm.JdbcConnection
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertThrows
import org.junit.jupiter.api.Test

class ActivityEmailMigrationTest {
    @Test
    fun `email migration backfills existing activities before enforcing constraints`() {
        DriverManager.getConnection("jdbc:h2:mem:${UUID.randomUUID()};MODE=PostgreSQL;DATABASE_TO_UPPER=false").use { connection ->
            connection.createStatement().use { statement ->
                statement.execute("CREATE TABLE activity (id UUID PRIMARY KEY)")
                statement.execute("INSERT INTO activity VALUES ('00000000-0000-0000-0000-000000000002'), ('00000000-0000-0000-0000-000000000001')")
            }
            val database = H2Database().apply { this.connection = JdbcConnection(connection) }
            CommandScope("update")
                .addArgumentValue("changelogFile", "db/changelog/0023-add-activity-email-prefix.yaml")
                .addArgumentValue("database", database)
                .execute()

            connection.createStatement().use { statement ->
                statement.executeQuery("SELECT email_prefix FROM activity ORDER BY id").use { rows ->
                    val prefixes = buildList { while (rows.next()) add(rows.getString(1)) }
                    assertEquals(listOf("1000", "1001"), prefixes)
                }
                assertThrows(SQLException::class.java) {
                    statement.execute("INSERT INTO activity (id) VALUES (RANDOM_UUID())")
                }
                assertThrows(SQLException::class.java) {
                    statement.execute("INSERT INTO activity (id, email_prefix) VALUES (RANDOM_UUID(), '1000')")
                }
            }
        }
    }
}
