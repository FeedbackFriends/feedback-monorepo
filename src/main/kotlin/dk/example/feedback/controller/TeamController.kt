//package dk.example.feedback.controller
//
//import dk.example.feedback.model.TeamDto
//import dk.example.feedback.service.TeamService
//import org.springframework.web.bind.annotation.*
//import java.security.Principal
//import java.util.UUID
//
//@RestController
//@RequestMapping("/team")
//class TeamController(val teamService: TeamService) {
//
//    data class CreateTeamInputDto(
//        val teamName: String,
//        val teamMembers: List<TeamMemberInputDto>
//    )
//
//    data class TeamMemberInputDto(
//        val accountId: String?,
//        val email: String
//    )
//
//    @PostMapping
//    fun createTeam(
//        principal: Principal,
//        @RequestBody input: CreateTeamInputDto
//    ): TeamDto {
//        val managerId = principal.name
//        return teamService.createTeam(teamName = input.teamName, managerId = managerId, teamMembers = input.teamMembers)
//    }
//
//    data class UpdateTeamInputDto(
//        val teamId: UUID,
//        val teamName: String,
//        val teamMembers: List<String>
//    )
//
//    @PutMapping
//    fun updateTeam(
//        principal: Principal,
//        @RequestBody input: UpdateTeamInputDto
//    ): TeamDto {
//        val managerId = principal.name
//        TODO()
////        return teamService.updateTeam(
////            teamId = input.teamId,
////            teamName = input.teamName,
////            managerId = managerId,
////            teamMembers = input.teamMembers
////        )
//    }
//
//    @DeleteMapping("/{teamId}")
//    fun deleteTeam(
//        principal: Principal,
//        @PathVariable teamId: UUID
//    ) {
//        val managerId = principal.name
//        TODO()
////        teamService.deleteTeam(teamId = teamId, managerId = managerId)
//    }
//
//    data class RespondToInvitationInputDto(
//        val teamId: UUID,
//        val accountId: String,
//        val accepted: Boolean
//    )
//
//    @PostMapping("/respond_to_invitation")
//    fun respondToInvitation(
//        principal: Principal,
//        @RequestBody input: RespondToInvitationInputDto
//    ) {
//        val accountId = principal.name
//        TODO()
////        teamService.respondToInvitation(teamId = input.teamId, accountId = accountId, accepted = input.accepted)
//    }
//
//    data class ReinviteTeamMemberInputDto(
//        val teamId: UUID,
//        val memberId: String
//    )
//
//    @PostMapping("/reinvite_team_member")
//    fun reinviteTeamMembers(
//        principal: Principal,
//        @RequestBody input: ReinviteTeamMemberInputDto
//    ) {
//        val managerId = principal.name
//        TODO()
////        teamService.reinviteTeamMembers(teamId = input.teamId, managerId = managerId, memberId = input.memberId)
//    }
//}
//
