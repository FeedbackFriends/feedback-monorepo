package dk.example.feedback

import ControllerPaths
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import dk.example.feedback.model.Role
import dk.example.feedback.persistence.table.AccountTable
import dk.example.feedback.service.FirebaseService
import jakarta.transaction.Transactional
import org.jetbrains.exposed.sql.deleteAll
import org.junit.jupiter.api.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import java.util.UUID

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

        // Add 10 Particiants

    }

    val getSessionRequest = MockMvcRequestBuilders
        .get(ControllerPaths.Session)
        .with (SecurityMockMvcRequestPostProcessors.jwt())
        .contentType(MediaType.APPLICATION_JSON)

    @Test
    fun integrationTest() {
        `AppOpen - Get session of anonymous firebase account, verify response`()
        `Login button tapped - Account role is set before login is shown`()
//        `Get session `
        `Successful login - Verify get session response`()

//        `Manager can create account`()
//        `Manager can update account`()
//        `Manager can create team with participant1 and participant2`()
//        `manager can edit team`()
        // manager can edit team
        // participant1 accepts, participant2 declines
        // manager can reinvite participant2
        // manager can create event with Team, and one with no team
        // manager can edit event
        // participants give feedback
    }

    @Test
    fun `AppOpen - Get session of anonymous firebase account, verify response`() {

        // Mock anonymous user
//        Mockito.`when`(firebaseService.getUser(userId = Mockito.anyString())).thenReturn(
//            null
//        )
//
//        mockMvc.perform(getSessionRequest).andExpect {
//            it.response.status = 200
//            val expectedSession = SessionDto(
//                accountInfo = null,
//                participantEvents = emptyList(),
//                managerData = null
//            )
//            val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
//            Assertions.assertEquals(expectedSession, actualSession)
//        }.andReturn()
    }


    @Test
    fun `Login button tapped - Account role is set before login is shown`() {

        val roleInput = Role.Manager

        val updateAccountRoleRequest = MockMvcRequestBuilders
            .post(ControllerPaths.Account.Role+"/${roleInput.name}")
            .with (SecurityMockMvcRequestPostProcessors.jwt())
            .contentType(MediaType.APPLICATION_JSON)

        mockMvc.perform(updateAccountRoleRequest).andExpect {
            it.response.status = 200
        }.andReturn()
    }

    @Test
    fun `Successful login - Verify get session response`() {

//        val displayName = "Nicolai Dam"
//        val email = "hello@hello.dk"
//        val phoneNumber = null
//
//        // Mock logged in user
//        Mockito.`when`(firebaseService.getUser(userId = Mockito.anyString())).thenReturn(
//            IFirebaseService.User(displayName = displayName, email = email, phoneNumber = phoneNumber)
//        )
//
//        mockMvc.perform(getSessionRequest).andExpect {
//            it.response.status = 200
//            val expectedSession = SessionDto(
//                accountInfo = SessionDto.AccountInfoDto(
//                    name = displayName,
//                    email = email,
//                    phoneNumber = phoneNumber,
//                ),
//                participantEvents = emptyList(),
//                managerData = SessionDto.ManagerDataDto(
//                    managerEvents = emptyList(),
//                    teams = emptyList()
//                )
//            )
//            val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
//            Assertions.assertEquals(expectedSession, actualSession)
//        }.andReturn()
    }


    //    @Test
//    @Order(1)
//    fun `Manager can create account`() {
//
//        val expectedUser = IFirebaseService.User(displayName = "Nicolai Dam", email = "hello@hello.dk", phoneNumber = null)
//
//        Mockito.`when`(firebaseService.getUser(userId = Mockito.anyString())).thenReturn(
//            expectedUser
//        )
//
//        val createUserInput = AccountController.CreateAccountInputDto(
//            fcmToken = fcmToken,
//            accountType = AccountType.Manager,
//            deviceId = deviceId
//        )
//        val createAccountRequest = MockMvcRequestBuilders
//            .post("/account")
//            .content(objectMapper.writeValueAsString(createUserInput))
//            .with (SecurityMockMvcRequestPostProcessors.jwt())
//            .contentType(MediaType.APPLICATION_JSON)
//
//        mockMvc.perform(createAccountRequest).andExpect {
//            it.response.status = 200
//        }.andReturn()
//
//        mockMvc.perform(getSessionRequest).andExpect {
//            it.response.status = 200
//            val expectedSession = SessionDto(
//                accountInfo = SessionDto.AccountInfoDto(
//                    name = "Nicolai Dam",
//                    email = "hello@hello.dk",
//                    phoneNumber = null,
//                ),
//                participantEvents = emptyList(),
//                managerData = SessionDto.ManagerDataDto(
//                    managerEvents = emptyList(),
//                    teams = emptyList()
//                )
//            )
//            val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
//            Assertions.assertEquals(expectedSession, actualSession)
//        }.andReturn()
//    }

    //    @Test
//    @Order(2)
//    fun `Manager can update account`() {
//        val updateAccountInput = AccountController.UpdateAccountInputDto(
//            name = "Nicolai Oyen Dam",
//            email = "new@email.dk",
//            phoneNumber = "12345678",
//            fcmToken = fcmToken,
//        )
//        val updateAccountRequest = MockMvcRequestBuilders
//            .put("/account")
//            .content(objectMapper.writeValueAsString(updateAccountInput))
//            .with (SecurityMockMvcRequestPostProcessors.jwt())
//            .contentType(MediaType.APPLICATION_JSON)
//        mockMvc.perform(updateAccountRequest).andExpect {
//            it.response.status = 200
//            val expectedResponse = SessionDto.AccountInfoDto(
//                name = "Nicolai Oyen Dam",
//                email = "new@email.dk",
//                phoneNumber = "12345678",
//            )
//            val actualResponse: SessionDto.AccountInfoDto = objectMapper.readValue(it.response.contentAsString, SessionDto.AccountInfoDto::class.java)
//            Assertions.assertEquals(expectedResponse, actualResponse)
//        }.andReturn()
//
//        mockMvc.perform(getSessionRequest).andExpect {
//            it.response.status = 200
//            val expectedSession = SessionDto(
//                accountInfo = SessionDto.AccountInfoDto(
//                    name = "Nicolai Oyen Dam",
//                    email = "new@email.dk",
//                    phoneNumber = "12345678",
//                ),
//                participantEvents = emptyList(),
//                managerData = SessionDto.ManagerDataDto(
//                    managerEvents = emptyList(),
//                    teams = emptyList()
//                )
//            )
//            val actualSession: SessionDto = objectMapper.readValue(it.response.contentAsString, SessionDto::class.java)
//            Assertions.assertEquals(expectedSession, actualSession)
//        }.andReturn()
//    }
//
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