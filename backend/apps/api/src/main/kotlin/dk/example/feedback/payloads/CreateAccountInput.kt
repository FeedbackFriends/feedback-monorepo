package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.Role

data class CreateAccountInput(
    val requestedRole: Role?,
    val fcmToken: String?
)
