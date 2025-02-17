package dk.example.feedback.dto

data class FeedbackSummaryDto(
    val totalFeedback: Int,
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)
