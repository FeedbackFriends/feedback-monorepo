//package dk.example.feedback.persistence.dao
//
//import dk.example.feedback.model.TeamMemberStatus
//import dk.example.feedback.model.db_models.TeamEntity
//import dk.example.feedback.persistence.table.TeamMemberTable
//import dk.example.feedback.persistence.table.TeamTable.default
//import org.jetbrains.exposed.dao.UUIDEntity
//import org.jetbrains.exposed.dao.UUIDEntityClass
//import org.jetbrains.exposed.dao.id.EntityID
//import java.util.*
//
//class TeamMemberDao(id: EntityID<UUID>): UUIDEntity(id) {
//
//    companion object : UUIDEntityClass<TeamMemberDao>(TeamMemberTable)
//
//    var account by AccountDao referencedOn TeamMemberTable.account
//    var team by TeamDao referencedOn TeamMemberTable.team
//    var status by TeamMemberTable.status.default(TeamMemberStatus.Invited)
//
//    fun toModel(): TeamEntity.TeamMember {
//        return TeamEntity.TeamMember(
//            account = account.toModel(),
//            memberStatus = status,
//        )
//    }
//}
