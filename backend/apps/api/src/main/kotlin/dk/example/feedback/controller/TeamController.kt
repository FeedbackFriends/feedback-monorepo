package dk.example.feedback.controller

import dk.example.feedback.model.team.*
import dk.example.feedback.persistence.repo.TeamRepo
import dk.example.feedback.service.TeamService
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.*
import java.util.UUID

data class CreateOrganizationInput(val id: UUID, val name: String, val teamId: UUID, val teamName: String)
data class CreateTeamInput(val id: UUID, val name: String)
data class InviteLeaderInput(val id: UUID, val email: String)
data class AcceptLeaderInput(val code: String)
data class JoinTeamInput(val id: UUID, val code: String, val name: String)

@RestController
@RequestMapping("/teams")
@PreAuthorize("isAuthenticated()")
class TeamController(private val teams: TeamRepo, private val service: TeamService) {
    @GetMapping("/leader-invitations/{code}")
    fun leaderInvitation(@PathVariable code: String): LeaderInvitationInfo = teams.leaderInvitation(service.code(code))

    @PostMapping("/leader-invitations/accept")
    fun acceptLeadership(@AuthenticationPrincipal jwt: Jwt, @RequestBody input: AcceptLeaderInput): TeamContext =
        service.acceptLeadership(jwt, input.code)

    @GetMapping("/{teamId}/leaders")
    fun leadership(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID): TeamLeadership =
        teams.leadership(service.actor(jwt), teamId)

    @PostMapping("/{teamId}/leaders/invitations")
    fun inviteLeader(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @RequestBody input: InviteLeaderInput): TeamLeadership =
        teams.inviteLeader(service.actor(jwt), teamId, input.id, service.email(input.email))

    @DeleteMapping("/{teamId}/leaders/invitations/{invitationId}")
    fun revokeLeaderInvite(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable invitationId: UUID): TeamLeadership =
        teams.revokeLeaderInvite(service.actor(jwt), teamId, invitationId)

    @DeleteMapping("/{teamId}/leaders/{accountId}")
    fun removeLeader(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable accountId: String): TeamLeadership =
        teams.removeLeader(service.actor(jwt), teamId, accountId)

    @GetMapping("/context")
    fun context(@AuthenticationPrincipal jwt: Jwt): TeamContext = teams.context(service.actor(jwt))

    @PostMapping("/organizations")
    fun createOrganization(@AuthenticationPrincipal jwt: Jwt, @RequestBody input: CreateOrganizationInput): TeamContext =
        service.createOrganization(jwt, input.id, input.name, input.teamId, input.teamName)

    @PostMapping("/organizations/{organizationId}")
    fun createTeam(@AuthenticationPrincipal jwt: Jwt, @PathVariable organizationId: UUID, @RequestBody input: CreateTeamInput): TeamInfo =
        teams.addTeam(service.actor(jwt), organizationId, input.id, service.name(input.name))

    @GetMapping("/invites/{code}")
    fun resolve(@PathVariable code: String): TeamInfo = teams.resolveInvite(service.code(code))

    @PostMapping("/requests")
    fun join(@AuthenticationPrincipal jwt: Jwt, @RequestBody input: JoinTeamInput): TeamContext =
        teams.join(service.actor(jwt), input.id, service.code(input.code), service.name(input.name))

    @DeleteMapping("/requests/{requestId}")
    fun cancel(@AuthenticationPrincipal jwt: Jwt, @PathVariable requestId: UUID): TeamContext =
        teams.cancel(service.actor(jwt), requestId)

    @DeleteMapping("/{teamId}/membership")
    fun leave(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID): TeamContext =
        teams.leave(service.actor(jwt), teamId)

    @GetMapping("/{teamId}")
    fun management(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID): TeamManagement =
        teams.management(service.actor(jwt), teamId)

    @PostMapping("/{teamId}/invite")
    fun rotate(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID): TeamManagement =
        teams.rotateInvite(service.actor(jwt), teamId)

    @PostMapping("/{teamId}/requests/{requestId}/approve")
    fun approve(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable requestId: UUID): TeamManagement =
        teams.decide(service.actor(jwt), teamId, requestId, true)

    @PostMapping("/{teamId}/requests/{requestId}/reject")
    fun reject(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable requestId: UUID): TeamManagement =
        teams.decide(service.actor(jwt), teamId, requestId, false)

    @DeleteMapping("/{teamId}/members/{accountId}")
    fun remove(@AuthenticationPrincipal jwt: Jwt, @PathVariable teamId: UUID, @PathVariable accountId: String): TeamManagement =
        teams.remove(service.actor(jwt), teamId, accountId)
}
