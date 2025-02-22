package dk.example.feedback.helpers

import dk.example.feedback.model.enumerations.Role
import org.slf4j.LoggerFactory
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component

data class AuthContext(
    val accountId: String,
    val role: Role?,
)

@Component
class AuthContextHelper {

    private val logger = LoggerFactory.getLogger(AuthContextHelper::class.java)

    fun getAuthContext(): AuthContext {
        val authentication = SecurityContextHolder.getContext().authentication

        if (authentication == null || !authentication.isAuthenticated) {
            logger.error("No authenticated user found in security context.")
            throw IllegalStateException("No authenticated user found.")
        }

        if (authentication.principal is Jwt) {
            val authContext = AuthContext(
                accountId = authentication.name,
                role = getRole(authentication.principal as Jwt),
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

    private fun getRole(jwt: Jwt): Role? {
        val roleValue = jwt.claims["role"] as? String ?: return null
        logger.info("Roles: $roleValue")
        return try {
            Role.valueOf(roleValue)
        } catch (e: IllegalArgumentException) {
            logger.error("Invalid role: $roleValue")
            null
        }
    }
}

