package dk.example.feedback.helpers

import dk.example.feedback.service.Claim
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component

data class AuthContext(
    val accountId: String,
    val customClaim: Claim?,
)

@Component
class AuthContextHelper {

    fun getAuthContext(): AuthContext {
        val authentication = SecurityContextHolder.getContext().authentication
        if (authentication.principal is Jwt) {
            return AuthContext(
                accountId = authentication.name,
                customClaim = (authentication.principal as Jwt).getCustomClaim(),
            )
        } else {
            throw IllegalStateException("Principal is not of type Jwt")
        }
    }
}

/**
 * Retrieves the custom claim from a JWT.
 *
 * Assumes the claim "custom_claims" is a list, and returns the first element if present.
 *
 * @return the custom claim as a [Claim], or null if not found or improperly structured.
 */
fun Jwt.getCustomClaim(): Claim? {
    return when (val claim = this.claims["custom_claims"]) {
        is List<*> -> claim.firstOrNull()?.toString()?.let { Claim.valueOf(it) }
        else -> null
    }
}
