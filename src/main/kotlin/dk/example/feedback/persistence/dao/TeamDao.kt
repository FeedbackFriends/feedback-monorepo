//package dk.example.feedback.persistence.dao
//
//import dk.example.feedback.model.db_models.TeamEntity
//import dk.example.feedback.persistence.table.EventTable
//import dk.example.feedback.persistence.table.TeamMemberTable
//import dk.example.feedback.persistence.table.TeamMemberTable.default
//import dk.example.feedback.persistence.table.TeamTable
//import org.jetbrains.exposed.dao.UUIDEntity
//import org.jetbrains.exposed.dao.UUIDEntityClass
//import org.jetbrains.exposed.dao.id.EntityID
//import java.time.OffsetDateTime
//import java.time.ZoneOffset
//import java.util.*
//
//class TeamDao(id: EntityID<UUID>): UUIDEntity(id) {
//
//    companion object : UUIDEntityClass<TeamDao>(TeamTable)
//
//    var teamName by TeamTable.name
//    var createdAt by TeamTable.createdAt.default(OffsetDateTime.now(ZoneOffset.UTC))
//    var updatedAt by TeamTable.updatedAt.default(OffsetDateTime.now(ZoneOffset.UTC))
//    var manager by AccountDao referencedOn TeamTable.manager
//    val teamMembers by TeamMemberDao referrersOn TeamMemberTable.team
//    val events by EventDao optionalReferrersOn EventTable.team
//
//    fun toModel(): TeamEntity {
//        return TeamEntity(
//            id = id.value,
//            teamName = teamName,
//            teamMembers = teamMembers.map { it.toModel() },
//            manager = manager.toModel(),
//        )
//    }
//}
