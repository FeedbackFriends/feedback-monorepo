package dk.example.feedback.tests

import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.persistence.repo.MockRepo
import dk.example.feedback.utils.TestConfig
import javax.sql.DataSource
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.test.context.TestPropertySource

@SpringBootTest
@Import(TestConfig::class, SecurityConfig::class)
@TestPropertySource(
    properties = [
        "spring.datasource.url=jdbc:h2:mem:mockseeddb;MODE=PostgreSQL;DATABASE_TO_UPPER=false",
    ]
)
class MockSeedDataTest(
    @Autowired private val dataSource: DataSource,
    @Autowired private val mockRepo: MockRepo,
) {

    @Test
    fun `mock seed inserts rich deterministic dataset and remains idempotent`() {
        assertEquals(61, count("account"))
        assertEquals(20, count("\"session\""))
        assertEquals(20, count("activity"))
        assertEquals(20, count("pin_code"))
        assertEquals(120, count("session_participant"))
        assertEquals(100, count("question"))
        assertEquals(200, count("feedback"))

        assertTrue(countWhere("session_participant", "feedback_submitted = true") > 0)
        assertTrue(countWhere("session_participant", "feedback_submitted = false") > 0)

        assertTrue(countWhere("feedback", "type = 'Comment'") > 0)
        assertTrue(countWhere("feedback", "type = 'Emoji'") > 0)
        assertTrue(countWhere("feedback", "type = 'ThumpsUpThumpsDown'") > 0)
        assertTrue(countWhere("feedback", "type = 'Opinion'") > 0)
        assertTrue(countWhere("feedback", "type = 'ZeroToTen'") > 0)

        val countsBefore = snapshotCounts()
        mockRepo.insertMockData()
        val countsAfter = snapshotCounts()

        assertEquals(countsBefore, countsAfter)
    }

    private fun count(tableName: String): Int {
        return querySingleInt("select count(*) from $tableName")
    }

    private fun countWhere(tableName: String, whereClause: String): Int {
        return querySingleInt("select count(*) from $tableName where $whereClause")
    }

    private fun querySingleInt(sql: String): Int {
        dataSource.connection.use { connection ->
            connection.createStatement().use { statement ->
                statement.executeQuery(sql).use { resultSet ->
                    check(resultSet.next()) { "No row returned for query: $sql" }
                    return resultSet.getInt(1)
                }
            }
        }
    }

    private fun snapshotCounts(): Map<String, Int> {
        return mapOf(
            "account" to count("account"),
            "session" to count("\"session\""),
            "activity" to count("activity"),
            "pin_code" to count("pin_code"),
            "session_participant" to count("session_participant"),
            "question" to count("question"),
            "feedback" to count("feedback"),
        )
    }
}
