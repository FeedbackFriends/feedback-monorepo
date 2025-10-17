package dk.example.feedback.dto

data class QuestionFeedbackSummaryDto(
    val emojiQuestionFeedbackSummary: EmojiQuestionFeedbackSummary? = null,
    val thumpsQuestionFeedbackSummary: ThumpsQuestionFeedbackSummary? = null,
    val opinionQuestionFeedbackSummary: OpinionQuestionFeedbackSummary? = null,
    val zeroToTenQuestionFeedbackSummary: ZeroToTenQuestionFeedbackSummary? = null,
)

data class ZeroToTenQuestionFeedbackSummary(
    val countValue0: Int,
    val countValue1: Int,
    val countValue2: Int,
    val countValue3: Int,
    val countValue4: Int,
    val countValue5: Int,
    val countValue6: Int,
    val countValue7: Int,
    val countValue8: Int,
    val countValue9: Int,
    val countValue10: Int,
    val percentageValue0: Double,
    val percentageValue1: Double,
    val percentageValue2: Double,
    val percentageValue3: Double,
    val percentageValue4: Double,
    val percentageValue5: Double,
    val percentageValue6: Double,
    val percentageValue7: Double,
    val percentageValue8: Double,
    val percentageValue9: Double,
    val percentageValue10: Double,
)

data class OpinionQuestionFeedbackSummary(
    val countStronglyAgree: Int,
    val countAgree: Int,
    val countStronglyDisagree: Int,
    val countDisagree: Int,
    val percentageStronglyAgree: Double,
    val percentageAgree: Double,
    val percentageStronglyDisagree: Double,
    val percentageDisagree: Double,
)

data class ThumpsQuestionFeedbackSummary(
    val countUp: Int,
    val countDown: Int,
    val percentageUp: Double,
    val percentageDown: Double,
)

data class EmojiQuestionFeedbackSummary(
    val countVerySad: Int,
    val countSad: Int,
    val countHappy: Int,
    val countVeryHappy: Int,
    val percentageVerySad: Double,
    val percentageSad: Double,
    val percentageHappy: Double,
    val percentageVeryHappy: Double,
)
