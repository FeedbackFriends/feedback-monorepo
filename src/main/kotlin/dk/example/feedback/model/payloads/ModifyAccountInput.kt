package dk.example.feedback.model.payloads

import dk.example.feedback.service.Claim

data class ModifyAccountInput(
    val accountDetails: AccountDetails,
    val requestedClaim: Claim
)

data class AccountDetails(
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
)
