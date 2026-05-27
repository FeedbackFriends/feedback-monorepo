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
import dk.example.feedback.payloads.EventInput
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
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.content
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
    fun `manager creates activity then event from that activity`() {
        val managerId = "manager-event-flow"
        createAccount(managerId = managerId)

        val activityId = createActivity(managerId = managerId)

        mockMvc.perform(
            MockMvcRequestBuilders.post("/event")
                .content(
                    objectMapper.writeValueAsString(
                        EventInput(
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
            .andExpect(jsonPath("$.location").value("Oslo"))
            .andExpect(jsonPath("$.questionsSnapshot[0].text").value("How did the event go?"))
            .andExpect(jsonPath("$.questionsSnapshot[0].feedbackType").value("Emoji"))
            .andExpect(jsonPath("$.questionsSnapshot[1].text").value("What should we improve next time?"))
            .andExpect(jsonPath("$.questionsSnapshot[1].feedbackType").value("Comment"))
    }

    @Test
    fun `invited existing account auto joins created event`() {
        val managerId = "manager-auto-join"
        val inviteeId = "invitee-auto-join"
        val inviteeEmail = "invitee@example.com"

        createAccount(managerId = managerId)
        createParticipantAccount(accountId = inviteeId, email = inviteeEmail)

        val activityId = createActivity(managerId = managerId, invitedEmails = listOf(inviteeEmail))

        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/event")
                .content(
                    objectMapper.writeValueAsString(
                        EventInput(
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

        val eventId = objectMapper.readTree(response.response.contentAsString)
            .get("id")
            .asText()

        mockMvc.perform(
            MockMvcRequestBuilders.get("/bootstrap")
                .header("Authorization", "Bearer ${MockJwtFactory(inviteeId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.participantEvents[*].id").value(hasItem(eventId)))
    }

    @Test
    fun `bootstrap update returns 204 with empty body when hash is unchanged`() {
        val managerId = "manager-bootstrap-update-unchanged"
        createAccount(managerId = managerId)

        val bootstrapResponse = mockMvc.perform(
            MockMvcRequestBuilders.get("/bootstrap")
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        val bootstrapHash = objectMapper.readTree(bootstrapResponse.response.contentAsString)
            .get("managerData")
            .get("bootstrapHash")
            .asText()

        mockMvc.perform(
            MockMvcRequestBuilders.get("/bootstrap/bootstrap-update/$bootstrapHash")
                .header("Authorization", "Bearer ${MockJwtFactory(managerId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isNoContent)
            .andExpect(content().string(""))
    }

    @Test
    fun `account post uses requested participant role for bootstrap even when jwt role is manager`() {
        val accountId = "account-role-override-participant"

        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/account")
                .content(objectMapper.writeValueAsString(CreateAccountInput(requestedRole = Role.Participant, fcmToken = null)))
                .header("Authorization", "Bearer ${MockJwtFactory(accountId).managerToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        val body = objectMapper.readTree(response.response.contentAsString)
        assertEquals(Role.Participant.value, body.get("role").asText())
        assertEquals(true, body.get("managerData").isNull)
    }

    @Test
    fun `account post uses requested manager role for bootstrap even when jwt role is participant`() {
        val accountId = "account-role-override-manager"

        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/account")
                .content(objectMapper.writeValueAsString(CreateAccountInput(requestedRole = Role.Manager, fcmToken = null)))
                .header("Authorization", "Bearer ${MockJwtFactory(accountId).participantToken()}")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andReturn()

        val body = objectMapper.readTree(response.response.contentAsString)
        assertEquals(Role.Manager.value, body.get("role").asText())
        assertEquals(false, body.get("managerData").isNull)
    }

    
    
    
    
    @Test
    fun `activity question update keeps old event snapshots and manager bootstrap aggregates question analytics`() {
        val managerId = "manager-question-analytics"
        val participantId = "participant-question-analytics"
        createAccount(managerId = managerId)
        createParticipantAccount(accountId = participantId, email = "participant.analytics@example.com")

        val activityResponse = createActivityResponse(managerId = managerId)
        val activityId = activityResponse.get("id").asText()
        val canonicalQuestionId = UUID.fromString(activityResponse.get("currentQuestions").get(0).get("id").asText())

        val firstEvent = createEvent(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-03T09:00:00+00:00"),
            location = "Oslo",
        )
        val firstEventPinCode = firstEvent.get("pinCode").asText()
        val firstEventQuestionId = UUID.fromString(firstEvent.get("questionsSnapshot").get(0).get("id").asText())

        submitEmojiFeedback(
            participantId = participantId,
            pinCode = firstEventPinCode,
            questionId = firstEventQuestionId,
        )

        val updatedActivity = updateActivity(
            managerId = managerId,
            activityId = activityId,
            questions = listOf(
                QuestionInput(
                    id = canonicalQuestionId,
                    questionText = "How did the event go?",
                    feedbackType = FeedbackType.Emoji,
                ),
                QuestionInput(
                    questionText = "What should we continue doing?",
                    feedbackType = FeedbackType.Comment,
                ),
            ),
        )

        val preservedFirstEvent = updatedActivity
            .get("events")
            .first { it.get("location").asText() == "Oslo" }
        assertEquals(
            "What should we improve next time?",
            preservedFirstEvent.get("questionsSnapshot").get(1).get("text").asText(),
        )
        assertEquals(
            "Comment",
            preservedFirstEvent.get("questionsSnapshot").get(1).get("feedbackType").asText(),
        )

        val secondEvent = createEvent(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-10T09:00:00+00:00"),
            location = "Bergen",
        )
        val secondEventPinCode = secondEvent.get("pinCode").asText()
        val secondEventQuestionId = UUID.fromString(secondEvent.get("questionsSnapshot").get(0).get("id").asText())
        assertEquals("Emoji", secondEvent.get("questionsSnapshot").get(0).get("feedbackType").asText())

        submitEmojiFeedback(
            participantId = participantId,
            pinCode = secondEventPinCode,
            questionId = secondEventQuestionId,
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
        assertEquals(2, analyticsEntry!!.get("eventCount").asInt())
        assertEquals(2, analyticsEntry.get("responseCount").asInt())
        assertEquals("How did the event go?", analyticsEntry.get("questionText").asText())
        assertEquals(2, analyticsEntry.get("timeline").size())
        assertEquals(2, analyticsEntry.get("overallSummary").get("emojiQuestionFeedbackSummary").get("countHappy").asInt())
    }

    @Test
    fun `activity trend uses latest two comparable zero-to-ten events with 0 to 5 normalization`() {
        val managerId = "manager-activity-trend"
        val participantId = "participant-activity-trend"
        createAccount(managerId = managerId)
        createParticipantAccount(accountId = participantId, email = "participant.trend@example.com")

        val activityId = createActivityWithZeroToTenQuestion(managerId = managerId)

        val firstEvent = createEvent(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-12T09:00:00+00:00"),
            location = "Trend-1",
        )
        submitZeroToTenFeedback(
            participantId = participantId,
            pinCode = firstEvent.get("pinCode").asText(),
            questionId = UUID.fromString(firstEvent.get("questionsSnapshot").get(0).get("id").asText()),
            score = 6,
        )

        val afterFirstEvent = fetchActivityFromBootstrap(managerId = managerId, activityId = activityId)
        assertEquals("insufficient_data", afterFirstEvent.get("trend").get("direction").asText())
        assertEquals("neutral", afterFirstEvent.get("trend").get("indicator").asText())
        assertEquals("average_rating", afterFirstEvent.get("trend").get("metric").asText())
        assertEquals(3.0, afterFirstEvent.get("trend").get("latestValue").asDouble())
        assertEquals(1, afterFirstEvent.get("trend").get("comparedEventCount").asInt())
        assertEquals(true, afterFirstEvent.get("trend").get("previousValue").isNull)
        assertEquals(true, afterFirstEvent.get("trend").get("delta").isNull)

        val secondEvent = createEvent(
            managerId = managerId,
            activityId = activityId,
            date = OffsetDateTime.parse("2026-04-19T09:00:00+00:00"),
            location = "Trend-2",
        )
        submitZeroToTenFeedback(
            participantId = participantId,
            pinCode = secondEvent.get("pinCode").asText(),
            questionId = UUID.fromString(secondEvent.get("questionsSnapshot").get(0).get("id").asText()),
            score = 8,
        )

        val afterSecondEvent = fetchActivityFromBootstrap(managerId = managerId, activityId = activityId)
        assertEquals("improving", afterSecondEvent.get("trend").get("direction").asText())
        assertEquals("positive", afterSecondEvent.get("trend").get("indicator").asText())
        assertEquals(4.0, afterSecondEvent.get("trend").get("latestValue").asDouble())
        assertEquals(3.0, afterSecondEvent.get("trend").get("previousValue").asDouble())
        assertEquals(1.0, afterSecondEvent.get("trend").get("delta").asDouble())
        assertEquals(2, afterSecondEvent.get("trend").get("comparedEventCount").asInt())
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
                                    questionText = "How did the event go?",
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
                                    questionText = "Rate this event",
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

    private fun createEvent(
        managerId: String,
        activityId: String,
        date: OffsetDateTime,
        location: String,
    ): JsonNode {
        val response = mockMvc.perform(
            MockMvcRequestBuilders.post("/event")
                .content(
                    objectMapper.writeValueAsString(
                        EventInput(
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
            .also { require(it.get("location").asText() == location) }
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
