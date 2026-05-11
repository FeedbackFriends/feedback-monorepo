package dk.example.feedback.service

import dk.example.feedback.dto.ManagerQuestionAnalyticsDto
import dk.example.feedback.dto.QuestionTrendPointDto
import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.model.database.QuestionEntity
import dk.example.feedback.model.database.EventEntity
import dk.example.feedback.model.enumerations.FeedbackType
import dk.example.feedback.persistence.repo.ActivityRepo
import dk.example.feedback.persistence.repo.EventRepo
import java.time.OffsetDateTime
import java.util.UUID
import org.springframework.stereotype.Service

@Service
class ManagerQuestionAnalyticsService(
    private val activityRepo: ActivityRepo,
    private val eventRepo: EventRepo,
) {

    fun getQuestionAnalytics(managerId: String): List<ManagerQuestionAnalyticsDto> {
        val currentQuestions = activityRepo
            .getManagerActivities(managerId)
            .flatMap { it.questions }
        val aggregatesById = linkedMapOf<UUID, QuestionAnalyticsAggregate>()

        currentQuestions.forEach { question ->
            val canonicalQuestionId = question.canonicalQuestionId()
            aggregatesById[canonicalQuestionId] = QuestionAnalyticsAggregate(
                canonicalQuestionId = canonicalQuestionId,
                questionText = question.questionText,
                feedbackType = question.feedbackType,
            )
        }

        eventRepo
            .getManagerEvents(managerId)
            .sortedBy { it.date }
            .forEach { event ->
                event.questions
                    .sortedBy { it.index }
                    .forEach { question ->
                        val canonicalQuestionId = question.canonicalQuestionId()
                        val aggregate = aggregatesById.getOrPut(canonicalQuestionId) {
                            QuestionAnalyticsAggregate(
                                canonicalQuestionId = canonicalQuestionId,
                                questionText = question.questionText,
                                feedbackType = question.feedbackType,
                            )
                        }
                        aggregate.recordEventQuestion(event = event, question = question)
                    }
            }

        return aggregatesById
            .values
            .sortedBy { it.questionText.lowercase() }
            .map { aggregate ->
                ManagerQuestionAnalyticsDto(
                    questionId = aggregate.canonicalQuestionId,
                    questionText = aggregate.questionText,
                    feedbackType = aggregate.feedbackType,
                    eventCount = aggregate.timeline.size,
                    responseCount = aggregate.feedback.size,
                    latestAskedAt = aggregate.latestAskedAt,
                    overallSummary = generateQuestionFeedbackSummary(
                        feedback = aggregate.feedback,
                        type = aggregate.feedbackType,
                    ),
                    timeline = aggregate.timeline.sortedBy { it.eventDate },
                )
            }
    }
}

private data class QuestionAnalyticsAggregate(
    val canonicalQuestionId: UUID,
    var questionText: String,
    var feedbackType: FeedbackType,
    val feedback: MutableList<FeedbackEntity> = mutableListOf(),
    val timeline: MutableList<QuestionTrendPointDto> = mutableListOf(),
    var latestAskedAt: OffsetDateTime? = null,
) {
    fun recordEventQuestion(event: EventEntity, question: QuestionEntity) {
        if (latestAskedAt == null || event.date.isAfter(latestAskedAt)) {
            latestAskedAt = event.date
            questionText = question.questionText
            feedbackType = question.feedbackType
        }
        feedback.addAll(question.feedback)
        timeline += QuestionTrendPointDto(
            eventId = event.id,
            eventDate = event.date,
            responseCount = question.feedback.size,
            summary = generateQuestionFeedbackSummary(
                feedback = question.feedback,
                type = question.feedbackType,
            ),
        )
    }
}

private fun QuestionEntity.canonicalQuestionId(): UUID = activityQuestionId ?: id
