package dk.example.feedback.persistence.table

import org.jetbrains.exposed.sql.Table

object OrganizationTable : Table("organization") {
    val id = uuid("id")
    val creator = reference("creator_id", AccountTable.id).uniqueIndex()
    val name = varchar("name", 100)
    override val primaryKey = PrimaryKey(id)
}
object TeamTable : Table("team") {
    val id = uuid("id")
    val organization = reference("organization_id", OrganizationTable.id)
    val name = varchar("name", 100)
    val inviteCode = varchar("invite_code", 64).uniqueIndex()
    override val primaryKey = PrimaryKey(id)
}
object TeamMembershipTable : Table("team_membership") {
    val account = reference("account_id", AccountTable.id)
    val team = reference("team_id", TeamTable.id)
    val name = varchar("name", 100)
    override val primaryKey = PrimaryKey(account)
}
object TeamRequestTable : Table("team_join_request") {
    val id = uuid("id")
    val account = reference("account_id", AccountTable.id)
    val team = reference("team_id", TeamTable.id)
    val name = varchar("name", 100)
    val current = bool("current_request").default(true)
    val status = varchar("status", 16)
    override val primaryKey = PrimaryKey(id)
}

object TeamLeaderTable : Table("team_leader") {
    val account = reference("account_id", AccountTable.id)
    val team = reference("team_id", TeamTable.id)
    val email = varchar("email", 254)
    override val primaryKey = PrimaryKey(account)
}
object LeaderInvitationTable : Table("team_leader_invitation") {
    val id = uuid("id")
    val team = reference("team_id", TeamTable.id)
    val email = varchar("email", 254)
    val code = varchar("code", 64).uniqueIndex()
    val expiresAt = long("expires_at")
    val revoked = bool("revoked").default(false)
    val acceptedBy = reference("accepted_by", AccountTable.id).nullable()
    override val primaryKey = PrimaryKey(id)
}
