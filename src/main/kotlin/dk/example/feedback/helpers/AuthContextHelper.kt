package dk.example.feedback.helpers

import dk.example.feedback.service.Claim
import org.slf4j.LoggerFactory
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component

data class AuthContext(
    val accountId: String,
    val customClaim: Claim?,
)

@Component
class AuthContextHelper {

    val logger = LoggerFactory.getLogger(AuthContextHelper::class.java)

    fun getAuthContext(): AuthContext {
        val authentication: org.springframework.security.core.Authentication = SecurityContextHolder.getContext().authentication
        if (authentication.principal is Jwt) {
            val authContext = AuthContext(
                accountId = authentication.name,
                customClaim = getCustomClaim(authentication.principal as Jwt),
            )
            logger.info("Auth context: $authContext")
            return authContext
        } else {
            logger.error("Principal is not of type Jwt")
            throw IllegalStateException("Principal is not of type Jwt")
        }
    }

    fun verifyLoggedInAccountHasId(id: String) {
        logger.info("Verifying logged in account has id: $id")
        val authContext = getAuthContext()
        if (authContext.accountId != id) {
            logger.error("User does not have access to this resource")
            throw IllegalStateException("User does not have access to this resource")
        }
    }

    private fun getCustomClaim(jwt: Jwt): Claim? {
        // Extract the "custom_claims" from the JWT claims
        val customClaimsValue = jwt.claims["custom_claims"] as? String ?: return null
        logger.info("Custom claims: $customClaimsValue")
        return try {
            Claim.valueOf(customClaimsValue)
        } catch (e: IllegalArgumentException) {
            logger.error("Invalid custom claim: $customClaimsValue")
            null
        }
    }
}

