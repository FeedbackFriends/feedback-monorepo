package dk.example.feedback.model.payloads

data class ModifyAccountInput(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)
