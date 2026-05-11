package dk.example.feedback.service

import dk.example.feedback.dto.BootstrapDto
import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.helpers.role
import dk.example.feedback.model.database.AccountEntity
import dk.example.feedback.model.enumerations.Role
import java.util.*
import org.slf4j.LoggerFactory
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service

@Service
class BootstrapService(
    private val eventService: EventService,
    private val activityService: ActivityService,
    private val managerQuestionAnalyticsService: ManagerQuestionAnalyticsService,
    val accountService: AccountService,
    val notificationHistoryService: NotificationHistoryService,
) {

    private val logger = LoggerFactory.getLogger(BootstrapService::class.java)

    fun getUpdatedEvent(jwt: Jwt, bootstrapVersion: UUID): BootstrapDto? {
        val accountId = jwt.getAccountId()
        val role = jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        if (account.bootstrapVersion == bootstrapVersion) {
            logger.info("Event hash is the same, no need to provide updated event")
            return null
        }
        return getBootstrapDto(
            accountId = accountId,
            role = role,
            account = account
        )
    }

    fun getEvent(jwt: Jwt): BootstrapDto {
        return getEvent(jwt = jwt, roleOverride = null)
    }

    fun getEvent(jwt: Jwt, roleOverride: Role?): BootstrapDto {
        val accountId = jwt.getAccountId()
        val role = roleOverride ?: jwt.role()
        val account = accountService.fetchAccount(accountId = accountId)
            ?: throw Exception("Account not found for id: $accountId")
        return getBootstrapDto(
            accountId = accountId,
            role = role,
            account = account
        )
    }

    private fun getBootstrapDto(
        accountId: String,
        role: Role?,
        account: AccountEntity,
    ): BootstrapDto {
        logger.info("Get bootstrap with role: $role")
        notificationHistoryService.movePendingNotificationsToNotificationHistoryAndReturn(accountId = accountId)
        val accountDto = BootstrapDto.AccountInfoDto(
            name = account.name,
            email = account.email,
            phoneNumber = account.phoneNumber,
        )
        val participantEvents = eventService.getParticipantEvents(accountId = accountId)
        val managerData = when (role) {
            Role.Manager -> {
                BootstrapDto.ManagerDataDto(
                    activities = activityService.getManagerActivities(accountId),
                    notificationHistory = notificationHistoryService.getNotificationHistory(accountId = accountId),
                    bootstrapHash = account.bootstrapVersion,
                    questionAnalytics = managerQuestionAnalyticsService.getQuestionAnalytics(accountId),
                )
            }

            Role.Participant, null -> null
        }
        return BootstrapDto(
            role = role,
            accountInfo = accountDto,
            participantEvents = participantEvents,
            managerData = managerData,
        )
    }
}
