package dk.example.feedback.helpers

import org.springframework.security.oauth2.jwt.Jwt

fun Jwt.getAccountId(): String {
    return this.subject
}
