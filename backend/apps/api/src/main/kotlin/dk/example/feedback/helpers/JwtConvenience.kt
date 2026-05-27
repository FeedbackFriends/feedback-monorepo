package dk.example.feedback.helpers

import dk.example.feedback.model.enumerations.Role
import org.springframework.security.oauth2.jwt.Jwt

fun Jwt.getAccountId(): String {
    return this.subject
}

fun Jwt.role(): Role? {
    val roleClaim = this.claims["role"] as? String ?: return null
    return Role.fromString(roleClaim)
}
