package dk.example.feedback.helpers

import dk.example.feedback.model.enumerations.Role
import org.springframework.security.oauth2.jwt.Jwt

fun Jwt.getAccountId(): String {
    return if (isSupabase()) "supabase:${this.subject}" else this.subject
}

fun Jwt.role(): Role? {
    if (isSupabase()) return if (getClaim<Boolean>("is_anonymous") == false) Role.Manager else null
    val roleClaim = this.claims["role"] as? String ?: return null
    return Role.fromString(roleClaim)
}

fun Jwt.isSupabase(): Boolean = issuer?.toString()?.trimEnd('/')?.endsWith("/auth/v1") == true
