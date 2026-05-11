package dk.example.feedback.tests

import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.persistence.repo.MockRepo
import dk.example.feedback.utils.TestConfig
import javax.sql.DataSource
import org.junit.jupiter.api.Assertions.assertEquals
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
    ],
)
class MockSeedDataTest(
    @Autowired private val dataSource: DataSource,
    @Autowired private val mockRepo: MockRepo,
) {

    @Test
    fun `manager with data seed inserts deterministic graph and is idempotent`() {
        val countsBefore = snapshotCounts()
        mockRepo.insertManagerWithData(managerId = "mock-manager-with-data")
        val countsAfterFirst = snapshotCounts()
        assertEquals(countsBefore["account"]!! + 2, countsAfterFirst["account"])
        assertEquals(countsBefore["activity"]!! + 1, countsAfterFirst["activity"])
        assertEquals(countsBefore["event"]!! + 1, countsAfterFirst["event"])
        assertEquals(countsBefore["question"]!! + 5, countsAfterFirst["question"])
        assertEquals(countsBefore["feedback"]!! + 20, countsAfterFirst["feedback"])

        mockRepo.insertManagerWithData(managerId = "mock-manager-with-data")
        assertEquals(countsAfterFirst, snapshotCounts())
    }

    @Test
    fun `participant with data seed inserts deterministic graph and is idempotent`() {
        val countsBefore = snapshotCounts()
        mockRepo.insertParticipantWithData(participantId = "mock-participant-with-data")
        val countsAfterFirst = snapshotCounts()
        assertEquals(countsBefore["account"]!! + 2, countsAfterFirst["account"])
        assertEquals(countsBefore["activity"]!! + 1, countsAfterFirst["activity"])
        assertEquals(countsBefore["event"]!! + 1, countsAfterFirst["event"])
        assertEquals(countsBefore["question"]!! + 5, countsAfterFirst["question"])
        assertEquals(countsBefore["feedback"]!! + 10, countsAfterFirst["feedback"])

        mockRepo.insertParticipantWithData(participantId = "mock-participant-with-data")
        assertEquals(countsAfterFirst, snapshotCounts())
    }

    private fun count(tableName: String): Int {
        dataSource.connection.use { connection ->
            connection.createStatement().use { statement ->
                statement.executeQuery("select count(*) from $tableName").use { resultSet ->
                    check(resultSet.next()) { "No row returned for count query" }
                    return resultSet.getInt(1)
                }
            }
        }
    }

    private fun snapshotCounts(): Map<String, Int> {
        return mapOf(
            "account" to count("account"),
            "activity" to count("activity"),
            "event" to count("\"event\""),
            "question" to count("question"),
            "feedback" to count("feedback"),
        )
    }
}
