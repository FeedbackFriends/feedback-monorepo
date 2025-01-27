package dk.example.feedback

import ControllerPaths
import dk.example.feedback.model.dto.SessionDto
import dk.example.feedback.model.payloads.CreateAccountInput
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.service.Claim
import dk.example.feedback.service.FirebaseService
import jakarta.transaction.Transactional
import java.util.*
import org.jetbrains.exposed.sql.deleteAll
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders

//@TestMethodOrder(MethodOrderer.OrderAnnotation::class)
@SpringBootTest
@Transactional
@AutoConfigureMockMvc
class ManagerIntegrationTest(
    @Autowired val mockMvc: MockMvc
) {

    val objectMapper = jacksonObjectMapper()
    val deviceId: UUID = UUID.fromString("3fa85f64-5717-4562-b3fc-2c963f66afa6")
    val fcmToken = "fcmtoken"

    @MockBean
    lateinit var firebaseService: FirebaseService

    @BeforeEach
    fun setup() {
//        Mockito.`when`(firebaseService.verifyToken(Mockito.anyString())).thenReturn(true)
//        firebaseService = Mockito.mock(IFirebaseService::class.java)

        AccountTable.deleteAll()
    }

    @Test
    fun integrationTest() {
        `AppOpen - Create anonymous account`()
        `Logged in - Create manager account`()
        `Create event`()
    }

    @Test
    fun `AppOpen - Create anonymous account`() {

        Mockito.`when`(firebaseService.setUserClaims(Mockito.anyString(), Mockito.any())).then { }

        val createUserInput = CreateAccountInput(requestedClaim = null)
        val createAccountRequest = MockMvcRequestBuilders
            .post(ControllerPaths.Account.ControllerUrl)
            .content(objectMapper.writeValueAsString(createUserInput))
            .with (SecurityMockMvcRequestPostProcessors.jwt())
            .contentType(MediaType.APPLICATION_JSON)

        mockMvc.perform(createAccountRequest).andExpect {
            it.response.status = 200
            val expectedSession = SessionDto(
                accountInfo = SessionDto.AccountInfoDto(
                    name = null,
                    email = null,
                    phoneNumber = null,
                ),
                participantEvents = emptyList(),
                managerData = null,
                claim = null
            )
            val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
            Assertions.assertEquals(expectedSession, actualSession)
        }.andReturn()

    }

    @Test
    fun `Logged in - Create manager account`() {

        Mockito.`when`(firebaseService.setUserClaims(Mockito.anyString(), Mockito.any())).then { }

        Mockito.`when`(firebaseService.getUser(Mockito.anyString())).thenReturn(
            FirebaseService.User(displayName = "Nicolai Dam", email = "nicolai@email.dk", phoneNumber = "12345678")
        )

        val createUserInput = CreateAccountInput(requestedClaim = Claim.Manager)
        val createAccountRequest = MockMvcRequestBuilders
            .post(ControllerPaths.Account.ControllerUrl)
            .content(objectMapper.writeValueAsString(createUserInput))
            .with (SecurityMockMvcRequestPostProcessors.jwt())
            .contentType(MediaType.APPLICATION_JSON)

        mockMvc.perform(createAccountRequest).andExpect {
            it.response.status = 200
            val expectedSession = SessionDto(
                accountInfo = SessionDto.AccountInfoDto(
                    name = "Nicolai Dam",
                    email = "nicolai@email.dk",
                    phoneNumber = "12345678",
                ),
                participantEvents = emptyList(),
                managerData = SessionDto.ManagerDataDto(
                    managerEvents = emptyList(),
                ),
                claim = Claim.Manager
            )
            val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
            Assertions.assertEquals(expectedSession, actualSession)
        }.andReturn()
    }

    fun `Create event`() {
//        val createEventInput = EventController.CreateEventInputDto(
//            eventName = "Event 1",
//            eventDescription = "Description 1",
//            eventDate = "2021-12-24",
//            eventTime = "12:00",
//            eventLocation = "Location 1",
//            eventParticipants = listOf("participant1", "participant2")
//        )
//        val createEventRequest = MockMvcRequestBuilders
//            .post(ControllerPaths.Event.ControllerUrl)
//            .content(objectMapper.writeValueAsString(createEventInput))
//            .with (SecurityMockMvcRequestPostProcessors.jwt())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createEventRequest).andExpect {
//            it.response.status = 200
//            val actualResponse: EventDto = objectMapper.readValue(it.response.contentAsString, EventDto::class.java)
//            val expectedResponse = EventDto(
//                id = actualResponse.id,
//                eventName = "Event 1",
//                eventDescription = "Description 1",
//                eventDate = "2021-12-24",
//                eventTime = "12:00",
//                eventLocation = "Location 1",
//                eventParticipants = listOf(
//                    EventParticipantDto(
//                        accountId = "participant1",
//                        name = "Participant 1",
//                        email = "
//        }
    }

//    fun `Manager can create team with participant1 and participant2`() {
//        val createTeamInput = TeamController.CreateTeamInputDto(
//            teamName = "Team 1",
//            teamMembers = listOf("participant1", "participant2")
//        )
//        val createTeamRequest = MockMvcRequestBuilders
//            .post("/team")
//            .content(objectMapper.writeValueAsString(createTeamInput))
//            .with (SecurityMockMvcRequestPostProcessors.jwt())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createTeamRequest).andExpect {
//            it.response.status = 200
//            val actualResponse: TeamDto = objectMapper.readValue(it.response.contentAsString, TeamDto::class.java)
//            val expectedResponse = TeamDto(
//                id = actualResponse.id,
//                teamName = "Team 1",
//                teamMembers = listOf(
//                    TeamMemberDto(
//                        accountId = "participant1",
//                        name = "Participant 1",
//                        email = "participant1@gmail.com",
//                        phoneNumber = null,
//                        memberStatus = TeamMemberStatus.Invited
//                    ),
//                    TeamMemberDto(
//                        accountId = "participant2",
//                        name = "Participant 2",
//                        email = "participant2@gmail.com",
//                        phoneNumber = null,
//                        memberStatus = TeamMemberStatus.Invited
//                    ),
//                )
//            )
//            Assertions.assertEquals(expectedResponse, actualResponse)
//
//            mockMvc.perform(getSessionRequest).andExpect {
//                it.response.status = 200
//                val expectedSession = SessionDto(
//                    accountInfo = SessionDto.AccountInfoDto(
//                        name = "Nicolai Oyen Dam",
//                        email = "new@email.dk",
//                        phoneNumber = "12345678",
//                    ),
//                    participantEvents = emptyList(),
//                    managerData = SessionDto.ManagerDataDto(
//                        managerEvents = emptyList(),
//                        teams = listOf(
//                            TeamDto(
//                                id = actualResponse.id,
//                                teamName = "Team 1",
//                                teamMembers = listOf(
//                                    TeamMemberDto(
//                                        accountId = "participant1",
//                                        name = "Participant 1",
//                                        email = "participant1@gmail.com",
//                                        phoneNumber = null,
//                                        memberStatus = TeamMemberStatus.Invited
//                                    ),
//                                    TeamMemberDto(
//                                        accountId = "participant2",
//                                        name = "Participant 2",
//                                        email = "participant2@gmail.com",
//                                        phoneNumber = null,
//                                        memberStatus = TeamMemberStatus.Invited
//                                    ),
//                                )
//                            )
//                        )
//                    )
//                )
//                val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
//                Assertions.assertEquals(expectedSession, actualSession)
//            }.andReturn()
//        }


//    fun `manager can edit team`() {
//        val editTeamInput = TeamController.EditTeamInputDto(
//            teamId = "teamId",
//            teamName = "Team 1",
//            teamMembers = listOf(
//                TeamMemberDto(
//                    accountId = "participant1",
//                    name = "Participant 1",
//                    email = "
//    }
}
