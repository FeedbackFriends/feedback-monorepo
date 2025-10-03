package dk.example.feedback.dto

data class QuestionFeedbackSummaryDto(
    val unseenCount: Int,
    val emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary? = null,
    val thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary? = null,
    val opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary? = null,
    val zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary? = null,
)

data class ZeroToTenQuestionFeedbackSummary(
    val zeroToTenFeedbackCountStats: ZeroToTenFeedbackCountStatsDto,
    val zeroToTenFeedbackSegmentationStats: ZeroToTenFeedbackCountSegmentationStatsDto,
)

data class ZeroToTenFeedbackCountStatsDto(
    val value0: Int,
    val value1: Int,
    val value2: Int,
    val value3: Int,
    val value4: Int,
    val value5: Int,
    val value6: Int,
    val value7: Int,
    val value8: Int,
    val value9: Int,
    val value10: Int,
    val commentsCount: Int,
)

data class ZeroToTenFeedbackCountSegmentationStatsDto(
    val value0Percentage: Double,
    val value1Percentage: Double,
    val value2Percentage: Double,
    val value3Percentage: Double,
    val value4Percentage: Double,
    val value5Percentage: Double,
    val value6Percentage: Double,
    val value7Percentage: Double,
    val value8Percentage: Double,
    val value9Percentage: Double,
    val value10Percentage: Double,
)

data class OpinionQuestionFeedbackSummary(
    val opinionFeedbackCountStats: OpinionFeedbackCountStatsDto,
    val opinionFeedbackSegmentationStats: OpinionFeedbackCountSegmentationStatsDto,
)

data class OpinionFeedbackCountStatsDto(
    val stronglyAgree: Int,
    val agree: Int,
    val stronglyDisagree: Int,
    val disagree: Int,
    val commentsCount: Int,
)

data class OpinionFeedbackCountSegmentationStatsDto(
    val stronglyAgreePercentage: Double,
    val agreePercentage: Double,
    val stronglyDisagreePercentage: Double,
    val disagreePercentage: Double,
)

data class ThumpsQuestionFeedbackSummary(
    val thumpsFeedbackCountStats: ThumpsFeedbackCountStatsDto,
    val thumpsFeedbackSegmentationStats: ThumpsFeedbackCountSegmentationStatsDto,
)

data class ThumpsFeedbackCountStatsDto(
    val upCount: Int,
    val downCount: Int,
    val commentsCount: Int,
)

data class ThumpsFeedbackCountSegmentationStatsDto(
    val upPercentage: Double,
    val downPercentage: Double,
)

data class EmojiQuestionFeedbackSummary(
    val emojiFeedbackCountStats: EmojiFeedbackCountStatsDto,
    val emojiFeedbackSegmentationStats: EmojiFeedbackSegmentationStatsDto,
)

data class EmojiFeedbackCountStatsDto(
    val verySadCount: Int,
    val sadCount: Int,
    val happyCount: Int,
    val veryHappyCount: Int,
    val commentsCount: Int,
)

data class EmojiFeedbackSegmentationStatsDto(
    val verySadPercentage: Double,
    val sadPercentage: Double,
    val happyPercentage: Double,
    val veryHappyPercentage: Double,
)
