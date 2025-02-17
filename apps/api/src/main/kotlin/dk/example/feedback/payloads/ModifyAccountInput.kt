package dk.example.feedback.payloads

data class ModifyAccountInput(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)
