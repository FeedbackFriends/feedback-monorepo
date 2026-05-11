package dk.example.feedback.dto

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Aggregated feedback summary for a event across all questions.")
data class OverallFeedbackSummaryDto(
    val segmentationStats: OverallFeedbackSegmentationStatsDto,
    val countStats: OverallFeedbackCountStatsDto,
    val unseenResponses: Int,
    val responses: Int,
)

@Schema(description = "Absolute counts of feedback outcomes in a event summary.")
data class OverallFeedbackCountStatsDto(
    val verySadCount: Int,
    val sadCount: Int,
    val happyCount: Int,
    val veryHappyCount: Int,
    val commentsCount: Int,
)

@Schema(description = "Percentage distribution of emoji feedback outcomes in a event summary.")
data class OverallFeedbackSegmentationStatsDto(
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)
