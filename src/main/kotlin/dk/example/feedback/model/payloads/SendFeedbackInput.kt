package dk.example.feedback.model.payloads

data class SendFeedbackInput(
        val feedback: List<FeedbackInput>,
        val pinCode: String,
    )
