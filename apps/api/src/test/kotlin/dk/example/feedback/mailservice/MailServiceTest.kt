//package dk.example.feedback.mailservice
//
//import com.fasterxml.jackson.databind.SerializationFeature
//import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
//import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
//import dk.example.feedback.config.SecurityConfig
//import dk.example.feedback.dto.FeedbackSessionDto
//import dk.example.feedback.helpers.role
//import dk.example.feedback.model.enumerations.Emoji
//import dk.example.feedback.model.enumerations.FeedbackType
//import dk.example.feedback.model.enumerations.Role
//import dk.example.feedback.payloads.CreateAccountInput
//import dk.example.feedback.payloads.EventInput
//import dk.example.feedback.payloads.FeedbackInput
//import dk.example.feedback.payloads.ModifyAccountInput
//import dk.example.feedback.payloads.QuestionInput
//import dk.example.feedback.payloads.StartFeedbackSessionInput
//import dk.example.feedback.payloads.SubmitFeedbackInput
//import dk.example.feedback.utils.MockJwtFactory
//import dk.example.feedback.utils.TestConfig
//import java.time.OffsetDateTime
//import kotlinx.coroutines.test.runTest
//import org.junit.jupiter.api.Test
//import org.springframework.beans.factory.annotation.Autowired
//import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
//import org.springframework.boot.test.context.SpringBootTest
//import org.springframework.context.annotation.Import
//import org.springframework.http.MediaType
//import org.springframework.security.core.authority.SimpleGrantedAuthority
//import org.springframework.security.oauth2.jwt.Jwt
//import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors
//import org.springframework.test.web.servlet.MockMvc
//import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
//import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
//import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
//
//@SpringBootTest
//@AutoConfigureMockMvc
//@Import(TestConfig::class, SecurityConfig::class)
//class AccountControllerTest(
//    @Autowired val mockMvc: MockMvc,
//
//) {
//    private val objectMapper = jacksonObjectMapper()
//        .registerModule(JavaTimeModule())
//        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
//
//    @Test
//    fun integration() = runTest {
//        val user1 = "User1"
//        `Create anonymous account and verify get session`(userId = user1)
//        `Upgrade account to participant role and verify get session`(userId = user1)
//        `Update account role to manager and verify get session`(userId = user1)
//        `Modify account and verify get session`(userId = user1)
//        val createdEvent = `Create event and verify session`(userId = user1)
////        `Delete event and verify session`(userId = user1, eventId = createdEvent.first)
////        val newCreatedEvent = `Create event and verify session`(userId = user1)
////        `Update event and verify session`(userId = user1, eventId = newCreatedEvent.first)
////        `Submit emoji feedback to event`(pinCode = newCreatedEvent.second, emoji = Emoji.VeryHappy, userId = "User2")
////        `Submit emoji feedback to event`(pinCode = newCreatedEvent.second, emoji = Emoji.Sad, userId = "User3")
////        `Verify event has new feedback`(userId = user1, newFeedback = 2)
////        `Trigger resetNewFeedback for event and verify session`(userId = user1, eventId = newCreatedEvent.first)
////        `Verify event has new feedback`(userId = user1, newFeedback = 0)
////        `A third user joins the event, verify session`()
////        ``()
//    }
//
//    suspend fun `Create anonymous account and verify get session`(userId: String) {
//        val createUserInput = CreateAccountInput(requestedRole = null, fcmToken = null)
//
//        val createAccountRequest = MockMvcRequestBuilders
//            .post("/account")
//            .content(objectMapper.writeValueAsString(createUserInput))
//            .with(MockJwtFactory(userId).anonymousToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createAccountRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(null))
//            .andExpect(jsonPath("$.accountInfo.name").value(null))
//            .andExpect(jsonPath("$.accountInfo.email").value(null))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value(null))
//            .andExpect(jsonPath("$.participantEvents").isEmpty)
//            .andExpect(jsonPath("$.managerData").value(null))
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).anonymousToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(null))
//            .andExpect(jsonPath("$.accountInfo.name").value(null))
//            .andExpect(jsonPath("$.accountInfo.email").value(null))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value(null))
//            .andExpect(jsonPath("$.participantEvents").isEmpty)
//            .andExpect(jsonPath("$.managerData").value(null))
//    }
//
//    suspend fun `Upgrade account to participant role and verify get session`(userId: String) {
//        val createUserInput = CreateAccountInput(requestedRole = Role.Participant, fcmToken = null)
//
//        val createAccountRequest = MockMvcRequestBuilders
//            .post("/account")
//            .content(objectMapper.writeValueAsString(createUserInput))
//            .with(MockJwtFactory(userId).anonymousToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createAccountRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(null))
//            .andExpect(jsonPath("$.accountInfo.name").value(null))
//            .andExpect(jsonPath("$.accountInfo.email").value(null))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value(null))
//            .andExpect(jsonPath("$.participantEvents").isEmpty)
//            .andExpect(jsonPath("$.managerData").value(null))
//        // TODO: remove response from create account endpoint
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).participantToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Participant.toString()))
//            .andExpect(jsonPath("$.accountInfo.name").value(null))
//            .andExpect(jsonPath("$.accountInfo.email").value(null))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value(null))
//            .andExpect(jsonPath("$.participantEvents").isEmpty)
//            .andExpect(jsonPath("$.managerData").value(null))
//    }
//
//    suspend fun `Update account role to manager and verify get session`(userId: String) {
//        val token = MockJwtFactory(userId = "user-id").managerToken()
//        mockMvc.perform(
//            MockMvcRequestBuilders.put("/account/role")
//                .with(MockJwtFactory(userId).participantToken())
//                .contentType(MediaType.APPLICATION_JSON)
//                .content("""{"role":"Manager"}""")
//        ).andExpect(status().isOk)
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Manager.toString()))
//            .andExpect(jsonPath("$.accountInfo.name").value(null))
//            .andExpect(jsonPath("$.accountInfo.email").value(null))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value(null))
//            .andExpect(jsonPath("$.participantEvents").isEmpty)
//            .andExpect(jsonPath("$.managerData").exists())
//    }
//
//    suspend fun `Modify account and verify get session`(userId: String) {
//        val modifyAccountInput = ModifyAccountInput(
//            name = "New name",
//            email = "New email",
//            phoneNumber = "New phone number"
//        )
//
//        val updateAccountRequest = MockMvcRequestBuilders
//            .put("/account")
//            .content(objectMapper.writeValueAsString(modifyAccountInput))
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(updateAccountRequest).andExpect(status().isOk)
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Manager.toString()))
//            .andExpect(jsonPath("$.accountInfo.name").value("New name"))
//            .andExpect(jsonPath("$.accountInfo.email").value("New email"))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value("New phone number"))
//            .andExpect(jsonPath("$.participantEvents").isEmpty)
//            .andExpect(jsonPath("$.managerData").exists())
//    }
//
//    suspend fun `Create event and verify session`(userId: String): Pair<String, String> {
//        val createEventInput = EventInput(
//            title = "Daily standup",
//            agenda = null,
//            date = OffsetDateTime.parse("2025-03-11T09:00:00+00:00"),
//            durationInMinutes = 60,
//            location = "Copenhagen",
//            questions = listOf(
//                QuestionInput(
//                    questionText = "What did you do yesterday?",
//                    feedbackType = FeedbackType.Emoji
//                ),
//                QuestionInput(
//                    questionText = "What will you do today?",
//                    feedbackType = FeedbackType.Emoji
//                )
//            ),
//        )
//
//        val createEventRequest = MockMvcRequestBuilders
//            .post("/event")
//            .content(objectMapper.writeValueAsString(createEventInput))
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        val createEventResponse = mockMvc.perform(createEventRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.event.title").value("Daily standup"))
//            .andExpect(jsonPath("$.event.location").value("Copenhagen"))
//            .andExpect(jsonPath("$.event.durationInMinutes").value(60))
//            .andExpect(jsonPath("$.event.questions").isArray)
//            .andExpect(jsonPath("$.event.questions[0].questionText").value("What did you do yesterday?"))
//            .andExpect(jsonPath("$.event.questions[0].feedbackType").value("Emoji"))
//            .andExpect(jsonPath("$.event.questions[1].questionText").value("What will you do today?"))
//            .andExpect(jsonPath("$.event.questions[1].feedbackType").value("Emoji"))
//            .andExpect(jsonPath("$.event.invitedEmails").isArray)
//            .andReturn()
//
//        val eventNode = objectMapper.readTree(createEventResponse.response.contentAsString).get("event")
//        val eventId: String = eventNode.get("id").asText()
//        val pincode: String = eventNode.get("pinCode").asText()
//
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Manager.toString()))
//            .andExpect(jsonPath("$.accountInfo.name").value("New name"))
//            .andExpect(jsonPath("$.accountInfo.email").value("New email"))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value("New phone number"))
//            .andExpect(jsonPath("$.participantEvents").isArray)
//            .andExpect(jsonPath("$.managerData").exists())
//            .andExpect(jsonPath("$.managerData.managerEvents").isArray)
//            .andExpect(jsonPath("$.managerData.managerEvents[0].title").value("Daily standup"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].location").value("Copenhagen"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].durationInMinutes").value(60))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions").isArray)
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[0].questionText").value("What did you do yesterday?"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[0].feedbackType").value("Emoji"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[1].questionText").value("What will you do today?"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[1].feedbackType").value("Emoji"))
//        return Pair(eventId, pincode)
//
//    }
//
//    suspend fun `Delete event and verify session`(userId: String, eventId: String) {
//        val deleteEventRequest = MockMvcRequestBuilders
//            .delete("/event/${eventId}")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(deleteEventRequest).andExpect(status().isOk)
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Manager.toString()))
//            .andExpect(jsonPath("$.accountInfo.name").value("New name"))
//            .andExpect(jsonPath("$.accountInfo.email").value("New email"))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value("New phone number"))
//            .andExpect(jsonPath("$.participantEvents").isArray)
//            .andExpect(jsonPath("$.managerData").exists())
//            .andExpect(jsonPath("$.managerData.managerEvents").isArray)
//            .andExpect(jsonPath("$.managerData.managerEvents").isEmpty)
//    }
//
//    suspend fun `Update event and verify session`(userId: String, eventId: String): String {
//        val updateEventInput = EventInput(
//            title = "New title",
//            agenda = null,
//            date = OffsetDateTime.parse("2025-03-11T09:00:00+00:00"),
//            durationInMinutes = 90,
//            location = "Copenhagen",
//            questions = listOf(
//                QuestionInput(
//                    questionText = "What will you do today?",
//                    feedbackType = FeedbackType.Emoji
//                ),
//                QuestionInput(
//                    questionText = "What did you do yesterday?",
//                    feedbackType = FeedbackType.Emoji
//                )
//            ),
//        )
//
//        val updateEventRequest = MockMvcRequestBuilders
//            .put("/event/${eventId}")
//            .content(objectMapper.writeValueAsString(updateEventInput))
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        val createEventResponse = mockMvc.perform(updateEventRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.event.title").value("New title"))
//            .andExpect(jsonPath("$.event.location").value("Copenhagen"))
//            .andExpect(jsonPath("$.event.durationInMinutes").value(90))
//            .andExpect(jsonPath("$.event.questions").isArray)
//            .andExpect(jsonPath("$.event.questions[1].questionText").value("What did you do yesterday?"))
//            .andExpect(jsonPath("$.event.questions[1].feedbackType").value("Emoji"))
//            .andExpect(jsonPath("$.event.questions[0].questionText").value("What will you do today?"))
//            .andExpect(jsonPath("$.event.questions[0].feedbackType").value("Emoji"))
//            .andExpect(jsonPath("$.event.invitedEmails").isArray)
//            .andReturn()
//
//        val eventId: String = objectMapper.readTree(createEventResponse.response.contentAsString)
//            .get("event").get("id").asText()
//
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Manager.toString()))
//            .andExpect(jsonPath("$.accountInfo.name").value("New name"))
//            .andExpect(jsonPath("$.accountInfo.email").value("New email"))
//            .andExpect(jsonPath("$.accountInfo.phoneNumber").value("New phone number"))
//            .andExpect(jsonPath("$.participantEvents").isArray)
//            .andExpect(jsonPath("$.managerData").exists())
//            .andExpect(jsonPath("$.managerData.managerEvents").isArray)
//            .andExpect(jsonPath("$.managerData.managerEvents[0].title").value("New title"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].location").value("Copenhagen"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].durationInMinutes").value(90))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions").isArray)
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[1].questionText").value("What did you do yesterday?"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[1].feedbackType").value("Emoji"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[0].questionText").value("What will you do today?"))
//            .andExpect(jsonPath("$.managerData.managerEvents[0].questions[0].feedbackType").value("Emoji"))
//        return eventId
//    }
//
//    suspend fun `Submit emoji feedback to event`(pinCode: String, emoji: Emoji, userId: String) {
//
//        val createUserInput = CreateAccountInput(requestedRole = null, fcmToken = null)
//
//        val createAccountRequest = MockMvcRequestBuilders
//            .post("/account")
//            .content(objectMapper.writeValueAsString(createUserInput))
//            .with(MockJwtFactory(userId = userId).anonymousToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createAccountRequest)
//
//
//        val startFeedbackSessionInput = StartFeedbackSessionInput(
//            pinCode = pinCode
//        )
//
//        val startFeedbackSessionRequest = MockMvcRequestBuilders
//            .post("/feedback/start")
//            .content(objectMapper.writeValueAsString(startFeedbackSessionInput))
//            .with(MockJwtFactory(userId = userId).anonymousToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        val startFeedbackSessionResponse = mockMvc.perform(startFeedbackSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.title").value("New title"))
//            .andExpect(jsonPath("$.agenda").value(null))
//            .andExpect(jsonPath("$.ownerInfo.name").value("New name"))
//            .andExpect(jsonPath("$.ownerInfo.email").value("New email"))
//            .andExpect(jsonPath("$.ownerInfo.phoneNumber").value("New phone number"))
//            .andReturn()
//
//        val submitFeedbackResponseDto = objectMapper.readValue(
//            startFeedbackSessionResponse.response.contentAsString,
//            FeedbackSessionDto::class.java
//        )
//        val feedbackInput: SubmitFeedbackInput = SubmitFeedbackInput(
//            feedback = submitFeedbackResponseDto.questions.map {
//                FeedbackInput(
//                    comment = null,
//                    emoji = emoji,
//                    thumbsUpThumpsDown = null,
//                    opinion = null,
//                    zeroToTen = null,
//                    questionId = it.id,
//                    feedbackType = FeedbackType.Emoji
//                )
//            },
//            pinCode = pinCode
//        )
//
//        val submitFeedbackSessionRequest = MockMvcRequestBuilders
//            .post("/feedback/submit")
//            .content(objectMapper.writeValueAsString(feedbackInput))
//            .with(MockJwtFactory(userId = userId).anonymousToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(submitFeedbackSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.shouldPresentRatingPrompt").value(false))
//    }
//
//    suspend fun `Verify event has new feedback`(userId: String, newFeedback: Int) {
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.managerData.managerEvents[0].invitedEmails").isArray)
//    }
//
//    suspend fun `Trigger resetNewFeedback for event and verify session`(userId: String, eventId: String) {
//        val getSessionRequest = MockMvcRequestBuilders
//            .put("/event/resetNewFeedback/${eventId}")
//            .with(MockJwtFactory(userId).managerToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//    }
//}
//
//
//fun jwtWithRole(token: Jwt): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor {
//    return SecurityMockMvcRequestPostProcessors.jwt().jwt(token).apply {
//        token.role()?.let { role ->
//            authorities(SimpleGrantedAuthority(role.value))
//        }
//    }
//}
