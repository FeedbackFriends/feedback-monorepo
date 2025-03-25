package dk.example.feedback.dto

data class UpdatedSessionDto(
    val events: List<ManagerEventDto>,
    val activity: ActivityDto,
)
