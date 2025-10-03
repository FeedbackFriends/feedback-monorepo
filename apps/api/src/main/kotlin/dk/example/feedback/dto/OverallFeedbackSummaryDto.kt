package dk.example.feedback.dto

data class OverallFeedbackSummaryDto(
    val segmentationStats: OverallFeedbackSegmentationStatsDto,
    val countStats: OverallFeedbackCountStatsDto,
    val unseenCount: Int,
    val totalUniqueParticipants: Int,
)

data class OverallFeedbackCountStatsDto(
    val verySadCount: Int,
    val sadCount: Int,
    val happyCount: Int,
    val veryHappyCount: Int,
    val commentsCount: Int,
)

data class OverallFeedbackSegmentationStatsDto(
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)