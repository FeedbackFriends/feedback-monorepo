package dk.example.feedback.payloads

data class SubmitFeedbackInput(
    val feedback: List<FeedbackInput>,
    val pinCode: String,
)
