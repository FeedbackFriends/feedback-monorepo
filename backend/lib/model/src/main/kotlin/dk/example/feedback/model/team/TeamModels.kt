package dk.example.feedback.model.team

import java.util.UUID

data class OrganizationInfo(val id: UUID, val name: String)
data class TeamInfo(val id: UUID, val organizationId: UUID, val organizationName: String, val name: String)
data class TeamMember(val accountId: String, val name: String)
data class TeamJoinRequest(val id: UUID, val team: TeamInfo, val name: String, val status: TeamRequestStatus)
enum class TeamRequestStatus { Pending, Rejected, Approved, Canceled }
data class TeamContext(
    val organization: OrganizationInfo? = null,
    val isOwner: Boolean = false,
    val managedTeams: List<TeamInfo> = emptyList(),
    val membership: TeamInfo? = null,
    val request: TeamJoinRequest? = null,
)
data class TeamManagement(
    val team: TeamInfo,
    val inviteCode: String,
    val members: List<TeamMember>,
    val pendingRequests: List<TeamJoinRequest>,
    val memberCount: Int,
)

data class TeamLeader(val accountId: String, val email: String)
data class LeaderInvitation(val id: UUID, val email: String, val code: String, val expiresAt: Long)
data class TeamLeadership(val leaders: List<TeamLeader>, val invitations: List<LeaderInvitation>)
data class LeaderInvitationInfo(val team: TeamInfo, val email: String)
