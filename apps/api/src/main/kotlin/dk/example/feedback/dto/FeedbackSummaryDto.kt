package dk.example.feedback.dto

data class FeedbackSummaryDto(
    val segmentationStats: FeedbackSegmentationStatsDto,
    val countStats: FeedbackCountStatsDto,
    val unseenCount: Int,
)

data class FeedbackCountStatsDto(
    val verySadCount: Int,
    val sadCount: Int,
    val happyCount: Int,
    val veryHappyCount: Int,
    val commentsCount: Int,
)

data class FeedbackSegmentationStatsDto(
    val uniqueParticipantFeedback: Int,
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)
