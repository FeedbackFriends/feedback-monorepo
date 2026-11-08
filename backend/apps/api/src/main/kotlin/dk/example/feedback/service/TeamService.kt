package dk.example.feedback.service

import dk.example.feedback.helpers.getAccountId
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.model.exceptions.InvalidTeamInputException
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.TeamRepo
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service
import java.util.UUID

@Service
class TeamService(private val teams: TeamRepo, private val accounts: AccountRepo,
    private val identities: SupabaseIdentityService, private val mail: LeaderInvitationMail) {
    fun actor(jwt: Jwt): String {
        val id = jwt.getAccountId()
        accounts.createOrGetAccount(null, null, null, id)
        return id
    }

    @org.springframework.transaction.annotation.Transactional
    fun createOrganization(jwt: Jwt, id: UUID, name: String, teamId: UUID, teamName: String, ownerName: String) = run {
        val email = identities.verifiedEmail(jwt)
        val actor = actor(jwt)
        val context = teams.createOrganization(actor, id, name(name), teamId, name(teamName))
        val existing = accounts.getAccount(actor)
        accounts.updateAccount(actor, name(ownerName), email, existing.phoneNumber)
        context
    }

    fun pendingInvitations(jwt: Jwt) = teams.pendingLeaderInvitations(identities.verifiedEmail(jwt))

    fun inviteLeader(jwt: Jwt, teamId: UUID, id: UUID, email: String) = run {
        val leadership = teams.inviteLeader(actor(jwt), teamId, id, email(email))
        val invitation = leadership.invitations.find { it.id == id }
            ?: throw dk.example.feedback.model.exceptions.TeamConflictException()
        mail.send(invitation)
        leadership
    }

    fun email(value: String): String = value.trim().lowercase(java.util.Locale.ROOT).also {
        if (it.length > 254 || !Regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$").matches(it)) throw InvalidTeamInputException()
    }

    fun acceptLeadership(jwt: Jwt, code: String) = run {
        val email = identities.verifiedEmail(jwt)
        teams.acceptLeadership(actor(jwt), code(code), email(email))
    }

    fun name(value: String): String = value.trim().also {
        if (it.isEmpty() || it.length > 100) throw InvalidTeamInputException()
    }

    fun code(value: String): String = value.trim().also {
        if (it.isEmpty() || it.length > 64) throw InvalidTeamInputException()
    }
}
