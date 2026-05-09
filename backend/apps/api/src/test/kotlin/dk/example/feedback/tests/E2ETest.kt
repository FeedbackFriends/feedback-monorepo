package dk.example.feedback.tests

import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.dto.ActivityInput
import dk.example.feedback.model.enumerations.Emoji
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.model.enumerations.ActivityRunMode
import dk.example.feedback.model.enumerations.Role
import dk.example.feedback.payloads.FeedbackInput
import dk.example.feedback.payloads.CreateAccountInput
import dk.example.feedback.payloads.ModifyAccountInput
import dk.example.feedback.payloads.QuestionInput
import dk.example.feedback.payloads.SessionInput
import dk.example.feedback.payloads.SubmitFeedbackInput
import dk.example.feedback.utils.MockJwtFactory
import dk.example.feedback.utils.TestConfig
import java.time.OffsetDateTime
import java.util.UUID
import org.hamcrest.Matchers.hasItem
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
class E2ETest(
    @Autowired val mockMvc: MockMvc,
) {
    private val objectMapper = jacksonObjectMapper()
        .registerModule(JavaTimeModule())
        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)

    @Test
    fun `manager creates activity then session from that activity`() {
        val managerId = "manager-session-flow"
        createAccount(managerId = managerId)

        val activityId = createActivity(managerId = managerId)

        mockMvc.perform(
            MockMvcRequestBuilders.post("/session")
                .content(
                    objectMapper.writeValueAsString(
                        SessionInput(
                            activityId = java.util.UUID.fromString(activityId),
                            date = OffsetDateTime.parse("2026-04-01T09:00:00+00:00"),
                            durationInMinutes = 30,
                            location = "Oslo",
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.id").value(activityId))
            .andExpect(jsonPath("$.sessions[0].location").value("Oslo"))
            .andExpect(jsonPath("$.currentQuestions[0].text").value("How did the session go?"))
            .andExpect(jsonPath("$.currentQuestions[1].text").value("What should we improve next time?"))
    }

    @Test
    fun `invited existing account auto joins created session`() {
        val managerId = "manager-auto-join"
        val inviteeId = "invitee-auto-join"
        val inviteeEmail = "invitee@example.com"

        createAccount(managerId = managerId)
        createParticipantAccount(accountId = inviteeId, email = inviteeEmail)

        val activityId = createActivity(managerId = managerId, invitedEmails = listOf(inviteeEmail))

        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/session")
                .content(
                    objectMapper.writeValueAsString(
                        SessionInput(
                            activityId = java.util.UUID.fromString(activityId),
                            date = OffsetDateTime.parse("2026-04-02T09:00:00+00:00"),
                            durationInMinutes = 45,
                            location = "Copenhagen",
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        val sessionId = objectMapper.readTree(response.response.contentAsString)
            .get("sessions")
            .get(0)
            .get("id")
            .asText()

        mockMvc.perform(
            MockMvcRequestBuilders.get("/bootstrap")
                .header("Authorization", "Bearer ${MockJwtFactory(inviteeId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.participantSessions[*].id").value(hasItem(sessionId)))
    }

    
    
    
    
    @Test
    fun `activity question update keeps old session snapshots and manager bootstrap aggregates question analytics`() {
        val managerId = "manager-question-analytics"
        val participantId = "participant-question-analytics"
        createAccount(managerId = managerId)
        createParticipantAccount(accountId = participantId, email = "participant.analytics@example.com")

        val activityResponse = createActivityResponse(managerId = managerId)
        val activityId = activityResponse.get("id").asText()
        val canonicalQuestionId = UUID.fromString(activityResponse.get("currentQuestions").get(0).get("id").asText())

        val firstSession = createSession(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-03T09:00:00+00:00"),
            location = "Oslo",
        )
        val firstSessionPinCode = firstSession.get("pinCode").asText()
        val firstSessionQuestionId = UUID.fromString(firstSession.get("questionsSnapshot").get(0).get("id").asText())

        submitEmojiFeedback(
            participantId = participantId,
            pinCode = firstSessionPinCode,
            questionId = firstSessionQuestionId,
        )

        val updatedActivity = updateActivity(
            managerId = managerId,
            activityId = activityId,
            questions = listOf(
                QuestionInput(
                    id = canonicalQuestionId,
                    questionText = "How did the session go?",
                    feedbackType = FeedbackType.Emoji,
                ),
                QuestionInput(
                    questionText = "What should we continue doing?",
                    feedbackType = FeedbackType.Comment,
                ),
            ),
        )

        val preservedFirstSession = updatedActivity
            .get("sessions")
            .first { it.get("location").asText() == "Oslo" }
        assertEquals(
            "What should we improve next time?",
            preservedFirstSession.get("questionsSnapshot").get(1).get("text").asText(),
        )

        val secondSession = createSession(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-10T09:00:00+00:00"),
            location = "Bergen",
        )
        val secondSessionPinCode = secondSession.get("pinCode").asText()
        val secondSessionQuestionId = UUID.fromString(secondSession.get("questionsSnapshot").get(0).get("id").asText())

        submitEmojiFeedback(
            participantId = participantId,
            pinCode = secondSessionPinCode,
            questionId = secondSessionQuestionId,
        )

        val bootstrapResponse = mockMvc.perform(
            MockMvcRequestBuilders.get("/bootstrap")
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        val bootstrapJson = objectMapper.readTree(bootstrapResponse.response.contentAsString)
        val analyticsEntry = bootstrapJson
            .get("managerData")
            .get("questionAnalytics")
            .firstOrNull { it.get("questionId").asText() == canonicalQuestionId.toString() }

        assertNotNull(analyticsEntry)
        assertEquals(2, analyticsEntry!!.get("sessionCount").asInt())
        assertEquals(2, analyticsEntry.get("responseCount").asInt())
        assertEquals("How did the session go?", analyticsEntry.get("questionText").asText())
        assertEquals(2, analyticsEntry.get("timeline").size())
        assertEquals(2, analyticsEntry.get("overallSummary").get("emojiQuestionFeedbackSummary").get("countHappy").asInt())
    }

    @Test
    fun `activity trend uses latest two comparable zero-to-ten sessions with 0 to 5 normalization`() {
        val managerId = "manager-activity-trend"
        val participantId = "participant-activity-trend"
        createAccount(managerId = managerId)
        createParticipantAccount(accountId = participantId, email = "participant.trend@example.com")

        val activityId = createActivityWithZeroToTenQuestion(managerId = managerId)

        val firstSession = createSession(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-12T09:00:00+00:00"),
            location = "Trend-1",
        )
        submitZeroToTenFeedback(
            participantId = participantId,
            pinCode = firstSession.get("pinCode").asText(),
            questionId = UUID.fromString(firstSession.get("questionsSnapshot").get(0).get("id").asText()),
            score = 6,
        )

        val afterFirstSession = fetchActivityFromBootstrap(managerId = managerId, activityId = activityId)
        assertEquals("insufficient_data", afterFirstSession.get("trend").get("direction").asText())
        assertEquals("neutral", afterFirstSession.get("trend").get("indicator").asText())
        assertEquals("average_rating", afterFirstSession.get("trend").get("metric").asText())
        assertEquals(3.0, afterFirstSession.get("trend").get("latestValue").asDouble())
        assertEquals(1, afterFirstSession.get("trend").get("comparedSessionCount").asInt())
        assertEquals(true, afterFirstSession.get("trend").get("previousValue").isNull)
        assertEquals(true, afterFirstSession.get("trend").get("delta").isNull)

        val secondSession = createSession(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-19T09:00:00+00:00"),
            location = "Trend-2",
        )
        submitZeroToTenFeedback(
            participantId = participantId,
            pinCode = secondSession.get("pinCode").asText(),
            questionId = UUID.fromString(secondSession.get("questionsSnapshot").get(0).get("id").asText()),
            score = 8,
        )

        val afterSecondSession = fetchActivityFromBootstrap(managerId = managerId, activityId = activityId)
        assertEquals("improving", afterSecondSession.get("trend").get("direction").asText())
        assertEquals("positive", afterSecondSession.get("trend").get("indicator").asText())
        assertEquals(4.0, afterSecondSession.get("trend").get("latestValue").asDouble())
        assertEquals(3.0, afterSecondSession.get("trend").get("previousValue").asDouble())
        assertEquals(1.0, afterSecondSession.get("trend").get("delta").asDouble())
        assertEquals(2, afterSecondSession.get("trend").get("comparedSessionCount").asInt())
    }

    private fun createAccount(managerId: String) {
        mockMvc.perform(
            MockMvcRequestBuilders.post("/account")
                .content(objectMapper.writeValueAsString(CreateAccountInput(requestedRole = Role.Manager, fcmToken = null)))
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        ).andExpect(status().isOk)
    }

    private fun createParticipantAccount(accountId: String, email: String) {
        mockMvc.perform(
            MockMvcRequestBuilders.post("/account")
                .content(objectMapper.writeValueAsString(CreateAccountInput(requestedRole = Role.Participant, fcmToken = null)))
                .header("Authorization", "Bearer ${MockJwtFactory(accountId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        ).andExpect(status().isOk)

        mockMvc.perform(
            MockMvcRequestBuilders.put("/account")
                .content(objectMapper.writeValueAsString(ModifyAccountInput(name = null, email = email, phoneNumber = null)))
                .header("Authorization", "Bearer ${MockJwtFactory(accountId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        ).andExpect(status().isOk)
    }

    private fun createActivity(managerId: String, invitedEmails: List<String> = emptyList()): String {
        return createActivityResponse(managerId = managerId, invitedEmails = invitedEmails).get("id").asText()
    }

    private fun createActivityResponse(managerId: String, invitedEmails: List<String> = emptyList()): JsonNode {
        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/activity")
                .content(
                    objectMapper.writeValueAsString(
                        ActivityInput(
                            title = "Weekly Retro",
                            agenda = "Review the week",
                            questions = listOf(
                                QuestionInput(
                                    questionText = "How did the session go?",
                                    feedbackType = dk.example.feedback.model.enumerations.FeedbackType.Emoji,
                                ),
                                QuestionInput(
                                    questionText = "What should we improve next time?",
                                    feedbackType = dk.example.feedback.model.enumerations.FeedbackType.Comment,
                                ),
                            ),
                            runMode = ActivityRunMode.MANUAL,
                            invitedEmails = invitedEmails,
                            sendEmails = false,
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        return objectMapper.readTree(response.response.contentAsString)
    }

    private fun createActivityWithZeroToTenQuestion(managerId: String): String {
        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/activity")
                .content(
                    objectMapper.writeValueAsString(
                        ActivityInput(
                            title = "Trend Activity",
                            agenda = "Track trend",
                            questions = listOf(
                                QuestionInput(
                                    questionText = "Rate this session",
                                    feedbackType = FeedbackType.ZeroToTen,
                                )
                            ),
                            runMode = ActivityRunMode.MANUAL,
                            invitedEmails = emptyList(),
                            sendEmails = false,
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        return objectMapper.readTree(response.response.contentAsString).get("id").asText()
    }

    private fun updateActivity(managerId: String, activityId: String, questions: List<QuestionInput>): JsonNode {
        val response = mockMvc.perform(
            MockMvcRequestBuilders.put("/activity/$activityId")
                .content(
                    objectMapper.writeValueAsString(
                        ActivityInput(
                            title = "Weekly Retro",
                            agenda = "Review the week",
                            questions = questions,
                            runMode = ActivityRunMode.MANUAL,
                            invitedEmails = emptyList(),
                            sendEmails = false,
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        return objectMapper.readTree(response.response.contentAsString)
    }

    private fun createSession(
        managerId: String,
        activityId: String,
        date: OffsetDateTime,
        location: String,
    ): JsonNode {
        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/session")
                .content(
                    objectMapper.writeValueAsString(
                        SessionInput(
                            activityId = UUID.fromString(activityId),
                            date = date,
                            durationInMinutes = 30,
                            location = location,
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        return objectMapper
            .readTree(response.response.contentAsString)
            .get("sessions")
            .first { it.get("location").asText() == location }
    }

    private fun submitEmojiFeedback(participantId: String, pinCode: String, questionId: UUID) {
        mockMvc.perform(
            MockMvcRequestBuilders.post("/feedback/submit")
                .content(
                    objectMapper.writeValueAsString(
                        SubmitFeedbackInput(
                            pinCode = pinCode,
                            feedback = listOf(
                                FeedbackInput(
                                    comment = null,
                                    emoji = Emoji.Happy,
                                    thumbsUpThumpsDown = null,
                                    opinion = null,
                                    zeroToTen = null,
                                    questionId = questionId,
                                    feedbackType = FeedbackType.Emoji,
                                )
                            ),
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(participantId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        ).andExpect(status().isOk)
    }

    private fun submitZeroToTenFeedback(participantId: String, pinCode: String, questionId: UUID, score: Int) {
        mockMvc.perform(
            MockMvcRequestBuilders.post("/feedback/submit")
                .content(
                    objectMapper.writeValueAsString(
                        SubmitFeedbackInput(
                            pinCode = pinCode,
                            feedback = listOf(
                                FeedbackInput(
                                    comment = null,
                                    emoji = null,
                                    thumbsUpThumpsDown = null,
                                    opinion = null,
                                    zeroToTen = score,
                                    questionId = questionId,
                                    feedbackType = FeedbackType.ZeroToTen,
                                )
                            ),
                        )
                    )
                )
                .header("Authorization", "Bearer ${MockJwtFactory(participantId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        ).andExpect(status().isOk)
    }

    private fun fetchActivityFromBootstrap(managerId: String, activityId: String): JsonNode {
        val response = mockMvc.perform(
            MockMvcRequestBuilders.get("/bootstrap")
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        val bootstrapJson = objectMapper.readTree(response.response.contentAsString)
        return bootstrapJson
            .get("managerData")
            .get("activities")
            .first { it.get("id").asText() == activityId }
    }
}
