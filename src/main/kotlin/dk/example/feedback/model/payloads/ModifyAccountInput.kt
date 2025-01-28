package dk.example.feedback.model.payloads

import dk.example.feedback.service.Claim

data class ModifyAccountInput(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
    val requestedClaim: Claim?,
)
