//package dk.example.feedback.event
//
//import com.fasterxml.jackson.databind.SerializationFeature
//import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
//import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
//import dk.example.feedback.config.SecurityConfig
//import dk.example.feedback.helpers.role
//import dk.example.feedback.model.enumerations.FeedbackType
//import dk.example.feedback.model.enumerations.Role
//import dk.example.feedback.payloads.CreateAccountInput
//import dk.example.feedback.payloads.EventInput
//import dk.example.feedback.payloads.ModifyAccountInput
//import dk.example.feedback.payloads.QuestionInput
//import dk.example.feedback.persistence.repo.AccountRepo
//import dk.example.feedback.persistence.table.AccountTable
//import dk.example.feedback.utils.FirebaseMockEngine
//import dk.example.feedback.utils.MockJwtFactory
//import dk.example.feedback.utils.TestConfig
//import java.time.OffsetDateTime
//import kotlinx.coroutines.runBlocking
//import kotlinx.coroutines.test.runTest
//import org.junit.jupiter.api.BeforeEach
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
//import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*
//
//@SpringBootTest
//@AutoConfigureMockMvc
//@Import(TestConfig::class, SecurityConfig::class)
//class EventControllerTest(
//    @Autowired val mockMvc: MockMvc,
//    @Autowired val firebaseService: FirebaseMockEngine,
//    val accountRepo: AccountRepo,
//) {
//    private val objectMapper = jacksonObjectMapper()
//        .registerModule(JavaTimeModule())
//        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
//
//
//    @Test
//    fun `Create event and verify session`() = runTest {
//
//        accountRepo.createOrGetAccount(
//            name = TODO(),
//            email = TODO(),
//            phoneNumber = TODO(),
//            accountId = TODO()
//        )
//
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
//            .with(firebaseService.getToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createEventRequest).andExpect(status().isOk)
//
//        val getSessionRequest = MockMvcRequestBuilders
//            .get("/session")
//            .with(firebaseService.getToken())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(getSessionRequest)
//            .andExpect(status().isOk)
//            .andExpect(jsonPath("$.role").value(Role.Organizer.toString()))
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
//
//    }
//}
//
//fun jwtWithRole(token: Jwt): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor {
//    return SecurityMockMvcRequestPostProcessors.jwt().jwt(token).apply {
//        token.role()?.let { role ->
//            authorities(SimpleGrantedAuthority(role.value))
//        }
//    }
//}
