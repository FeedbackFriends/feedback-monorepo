package dk.example.feedback.dto

data class FeedbackSegmentationStatsDto(
    val totalFeedback: Int,
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)
