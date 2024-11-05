package dk.example.feedback.helpers

import dk.example.feedback.service.Claim
import org.springframework.security.oauth2.jwt.Jwt

fun Jwt.getCustomClaim(): Claim? {
    val claim = this.claims["custom_claims"]
    return if (claim is List<*>) {
        return Claim.valueOf(claim[0].toString())
    } else {
        null
    }
}