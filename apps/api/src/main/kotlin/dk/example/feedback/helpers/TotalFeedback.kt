package dk.example.feedback.helpers

import dk.example.feedback.model.database.FeedbackEntity

fun List<FeedbackEntity>.totalUniqueParticipants(): Int {
    return this
        .distinctBy { it.participantId }
        .size
}
