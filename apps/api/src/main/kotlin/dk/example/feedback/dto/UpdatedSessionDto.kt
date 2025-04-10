package dk.example.feedback.dto

data class UpdatedSessionDto(
    val updatedManagerEvents: List<ManagerEventDto>?,
    val activity: ActivityDto,
    val recentlyUsedQuestions: List<SessionDto.RecentlyUsedQuestions>?,
)
