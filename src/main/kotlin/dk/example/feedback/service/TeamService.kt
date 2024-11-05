//package dk.example.feedback.service
//
//import dk.example.feedback.controller.TeamController
//import dk.example.feedback.model.TeamDto
//import dk.example.feedback.model.TeamMemberDto
//import dk.example.feedback.model.TeamMemberStatus
//import dk.example.feedback.persistence.dao.AccountDao
//import dk.example.feedback.persistence.repo.AccountRepo
//import dk.example.feedback.persistence.repo.TeamRepo
//import jakarta.transaction.Transactional
//import org.springframework.stereotype.Service
//import java.util.UUID
//
//@Service
//@Transactional
//class TeamService(val teamRepo: TeamRepo, val accountRepo: AccountRepo, val firebaseService: IFirebaseService) {
//
//    fun getAllTeams(accountId: String): List<TeamDto> {
//        return teamRepo.getAllTeams(accountId = accountId).map {
//            TeamDto(
//                id = it.id,
//                teamName = it.teamName,
//                teamMembers = it.teamMembers.map {
//                    TeamMemberDto(
//                        accountId = it.account.id,
//                        name = it.account.name!!,
//                        email = it.account.email!!,
//                        phoneNumber = it.account.phoneNumber,
//                        memberStatus = it.memberStatus,
//                    )
//                }
//            )
//        }
//    }
//
//    fun createTeam(teamName: String, managerId: String, teamMembers: List<TeamController.TeamMemberInputDto>): TeamDto {
//        val teamEntity = teamRepo.createTeam(teamName = teamName, managerId = managerId, teamMembers = teamMembers.map { it.email })
//        TODO("Fix alt det her")
////        // Send invite notification to team members
////        if (teamEntity.teamMembers.isNotEmpty()) {
////            val messages: List<IFirebaseService.Message> = teamMembers.map {
////                accountRepo.getAccountById(it)
////            }.mapNotNull {
////                it?.fcmToken
////            }.map {
////                IFirebaseService.Message(
////                    title = "Join team ${teamEntity.teamName}",
////                    body = "You have been invited by ${teamEntity.manager.name} to join the team",
////                    fcmToken = it,
////                    data = mapOf("teamId" to teamEntity.id.toString()),
////                )
////            }
////            firebaseService.sendNotifications(messages = messages)
////        }
//    TODO()
////        return TeamDto(
////            id = teamEntity.id,
////            teamName = teamEntity.teamName,
////            teamMembers = teamMembers.map {
////                val account = AccountDao.findById(id = it)!!.toModel()
////                TeamMemberDto(
////                    accountId =  account.id,
////                    name = account.name,
////                    email = account.email,
////                    phoneNumber = account.phoneNumber,
////                    memberStatus = TeamMemberStatus.Invited,
////                )
////            }
////        )
//    }
//
//    fun updateTeam(teamId: UUID, teamName: String, teamMembers: List<String>, managerId: String): TeamDto {
//        if (teamRepo.getTeam(teamId = teamId).manager.id != managerId) {
//            throw Exception("Only the manager of the team can update the team")
//        }
//        val updatedTeam =  teamRepo.updateTeam(teamId = teamId, teamName = teamName, teamMembers = teamMembers)
//        return TeamDto(
//            id = updatedTeam.id,
//            teamName = updatedTeam.teamName,
//            teamMembers = updatedTeam.teamMembers.map {
//                val account = AccountDao.findById(id = it.account.id)!!.toModel()
//                TeamMemberDto(
//                    accountId =  account.id,
//                    name = account.name!!,
//                    email = account.email!!,
//                    phoneNumber = account.phoneNumber,
//                    memberStatus = it.memberStatus,
//                )
//            }
//        )
//    }
//
//    fun deleteTeam(teamId: UUID, managerId: String) {
//        val team = teamRepo.getTeam(teamId = teamId)
//        if (team.manager.id != managerId) {
//            throw Exception("Only the manager of the team can update the team")
//        }
//        return teamRepo.deleteTeam(teamId = teamId)
//    }
//
//    fun respondToInvitation(teamId: UUID, accountId: String, accepted: Boolean) {
//        val status = if (accepted) TeamMemberStatus.Accepted else TeamMemberStatus.Declined
//        teamRepo.changeTeamMemberStatus(memberId = accountId, status = status, teamId = teamId)
//    }
//
//    fun reinviteTeamMembers(teamId: UUID, managerId: String, memberId: String) {
//        val team = teamRepo.getTeam(teamId = teamId)
//        teamRepo.changeTeamMemberStatus(memberId = memberId, status = TeamMemberStatus.Invited, teamId = team.id)
//        val memberAccount = accountRepo.getAccountById(memberId)
//        if (memberAccount?.fcmToken != null) {
//            val message = IFirebaseService.Message(
//                title = "Join team ${team.teamName}",
//                body = "You have been invited again by ${team.manager.name}. Please join the team",
//                fcmToken = memberAccount.fcmToken,
//                data = mapOf("teamId" to team.id.toString()),
//            )
//            firebaseService.sendNotifications(messages = listOf(message))
//        }
//    }
//}