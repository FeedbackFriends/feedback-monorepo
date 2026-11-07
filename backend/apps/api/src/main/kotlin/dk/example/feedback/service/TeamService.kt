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
class TeamService(private val teams: TeamRepo, private val accounts: AccountRepo) {
    fun actor(jwt: Jwt): String {
        val id = jwt.getAccountId()
        accounts.createOrGetAccount(null, null, null, id)
        return id
    }

    fun createOrganization(jwt: Jwt, id: UUID, name: String, teamId: UUID, teamName: String) = run {
        val firebase = jwt.getClaim<Map<String, Any>>("firebase")
        if (firebase?.get("sign_in_provider") != "google.com") {
            throw ForbiddenResourceAccessException("Google authentication required")
        }
        teams.createOrganization(actor(jwt), id, name(name), teamId, name(teamName))
    }

    fun email(value: String): String = value.trim().lowercase(java.util.Locale.ROOT).also {
        if (it.length > 254 || !Regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$").matches(it)) throw InvalidTeamInputException()
    }

    fun acceptLeadership(jwt: Jwt, code: String) = run {
        val firebase = jwt.getClaim<Map<String, Any>>("firebase")
        if (firebase?.get("sign_in_provider") != "google.com" || jwt.getClaim<Boolean>("email_verified") != true) {
            throw ForbiddenResourceAccessException("Verified Google email required")
        }
        val email = jwt.getClaim<String>("email") ?: throw ForbiddenResourceAccessException("Email required")
        teams.acceptLeadership(actor(jwt), code(code), email(email))
    }

    fun name(value: String): String = value.trim().also {
        if (it.isEmpty() || it.length > 100) throw InvalidTeamInputException()
    }

    fun code(value: String): String = value.trim().also {
        if (it.isEmpty() || it.length > 64) throw InvalidTeamInputException()
    }
}
