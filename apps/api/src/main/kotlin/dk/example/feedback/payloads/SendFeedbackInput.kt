package dk.example.feedback.payloads

data class SendFeedbackInput(
    val feedback: List<FeedbackInput>,
    val pinCode: String,
)
