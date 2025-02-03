package dk.example.feedback.model.payloads

import dk.example.feedback.service.Claim

data class UpdateClaimInput(
    val claim: Claim
)
