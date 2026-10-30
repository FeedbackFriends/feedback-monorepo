package dk.example.feedback.tests

import java.sql.DriverManager
import java.util.UUID
import liquibase.command.CommandScope
import liquibase.database.core.H2Database
import liquibase.database.jvm.JdbcConnection
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class PrelaunchResetMigrationTest {
    @Test
    fun `prelaunch reset clears app data only once and preserves migration history`() {
        DriverManager.getConnection("jdbc:h2:mem:${UUID.randomUUID()};MODE=PostgreSQL").use { connection ->
            val tables = listOf(
                "account", "activity", "event", "question", "feedback", "event_participant",
                "activity_invite", "pin_code", "fcm_token", "new_feedback_notification",
                "notification_history", "mail_listener_state", "zoho_processed_message",
            )
            connection.createStatement().use { statement ->
                tables.forEach { table ->
                    val parent = when (table) {
                        "activity" -> "account"
                        "event" -> "activity"
                        "question" -> "event"
                        "feedback" -> "question"
                        else -> null
                    }
                    val foreignKey = parent?.let { ", parent_id INT DEFAULT 1 REFERENCES $it(id)" } ?: ""
                    statement.execute("CREATE TABLE $table (id INT PRIMARY KEY$foreignKey)")
                    statement.execute("INSERT INTO $table (id) VALUES (1)")
                }
            }
            val database = H2Database().apply { this.connection = JdbcConnection(connection) }
            fun migrate() {
                CommandScope("update")
                    .addArgumentValue("changelogFile", "db/changelog/0025-reset-prelaunch-data.yaml")
                    .addArgumentValue("database", database)
                    .execute()
            }
            fun count(table: String): Int = connection.createStatement().use { statement ->
                statement.executeQuery("SELECT COUNT(*) FROM $table").use { rows ->
                    rows.next()
                    rows.getInt(1)
                }
            }

            migrate()
            tables.forEach { assertEquals(0, count(it), it) }
            assertEquals(1, count("DATABASECHANGELOG"))
            connection.createStatement().use { it.execute("INSERT INTO account (id) VALUES (2)") }
            migrate()
            assertEquals(1, count("account"), "A later startup must retain new data")
            assertEquals(1, count("DATABASECHANGELOG"))
        }
    }
}
