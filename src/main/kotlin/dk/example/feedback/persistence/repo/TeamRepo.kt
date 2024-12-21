//package dk.example.feedback.persistence.repo
//
//import dk.example.feedback.model.TeamDto
//import dk.example.feedback.model.db_models.TeamEntity
//import dk.example.feedback.model.TeamMemberStatus
//import dk.example.feedback.persistence.dao.*
//import dk.example.feedback.persistence.table.TeamMemberTable
//import dk.example.feedback.persistence.table.TeamTable
//import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
//import org.jetbrains.exposed.sql.and
//import org.jetbrains.exposed.sql.batchInsert
//import org.springframework.stereotype.Component
//import org.springframework.transaction.annotation.Transactional
//import java.time.OffsetDateTime
//import java.util.*
//
//@Transactional
//@Component
//class TeamRepo {
//
//    fun getAllTeams(accountId: String): List<TeamEntity> {
//        return TeamDao.find { TeamTable.manager eq accountId }.map { it.toModel() }
//    }
//
//    fun getTeam(teamId: UUID): TeamEntity {
//        return TeamDao.findById(teamId)?.toModel() ?: throw IllegalArgumentException("Team not found")
//    }
//
//    fun createTeam(teamName: String, managerId: String, teamMembers: List<String>): TeamEntity {
//        val team = TeamDao.new {
//            this.teamName = teamName
//            this.manager = AccountDao.findById(managerId) ?: throw IllegalArgumentException("Manager not found")
//            this.createdAt = OffsetDateTime.now()
//            this.updatedAt = OffsetDateTime.now()
//        }
//        TeamMemberTable.batchInsert(teamMembers) {
//            this[TeamMemberTable.team] = team.id
//            this[TeamMemberTable.account] = it
//            this[TeamMemberTable.status] = TeamMemberStatus.Invited
//        }
//        return team.toModel()
//    }
//
//    fun updateTeam(teamId: UUID, teamName: String, teamMembers: List<String>): TeamEntity {
//        val team = TeamDao.findById(teamId)?.apply {
//            this.teamName = teamName
//        } ?: throw IllegalArgumentException("Team not found")
//        TeamMemberDao.find { TeamMemberTable.team eq teamId }.forEach { it.delete() }
//        TeamMemberTable.batchInsert(teamMembers) {
//            this[TeamMemberTable.team] = teamId
//            this[TeamMemberTable.account] = it
//        }
//        return TeamEntity(
//            id = team.id.value,
//            teamName = team.teamName,
//            teamMembers = teamMembers.map {
//            TeamEntity.TeamMember(account = AccountDao.findById(id = it)!!.toModel(), memberStatus = TeamMemberStatus.Invited)
//            },
//            manager = AccountDao.findById(id = team.manager.id.value)!!.toModel()
//        )
//    }
//
//    fun deleteTeam(teamId: UUID) {
//        TeamDao.findById(teamId)?.delete() ?: throw IllegalArgumentException("Team not found")
//    }
//
//    fun changeTeamMemberStatus(memberId: String, status: TeamMemberStatus, teamId: UUID) {
//        TeamMemberDao.find { (TeamMemberTable.team eq teamId) and (TeamMemberTable.account eq memberId) }.first().apply {
//            this.status = status
//        }
//    }
//
//    fun getTeamMembers(teamId: UUID): List<TeamEntity.TeamMember> {
//        return TeamMemberDao.find(TeamMemberTable.team eq teamId).map { it.toModel() }
//    }
//
//    fun getTeamMembers(participantId: String): List<TeamEntity.TeamMember> {
//        return TeamMemberDao.find(TeamMemberTable.account eq participantId).map { it.toModel() }
//    }
//}
