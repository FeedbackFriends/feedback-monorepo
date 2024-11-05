package dk.example.feedback.model

import java.util.*

data class TeamDto(
    val id: UUID,
    val teamName: String,
    val teamMembers: List<TeamMemberDto>,
)

data class TeamMemberDto(
    val accountId: String,
    val name: String,
    val email: String,
    val phoneNumber: String?,
    val memberStatus: TeamMemberStatus,
)

