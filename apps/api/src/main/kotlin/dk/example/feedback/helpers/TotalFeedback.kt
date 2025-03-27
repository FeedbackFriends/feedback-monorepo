package dk.example.feedback.helpers

import dk.example.feedback.model.database.FeedbackEntity

fun List<FeedbackEntity>.totalUniqueFeedback(): Int {
    return this
        .distinctBy { it.participantId }
        .size
}
