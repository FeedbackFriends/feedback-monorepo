package dk.example.feedback.model.database

import java.util.*

data class AccountEntity(
    val id: String, // Internal identity: Supabase subjects are prefixed with supabase:; legacy IDs remain untouched.
    val fcmTokens: List<String>,
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
    val ratingPrompted: Boolean,
    val bootstrapVersion: UUID,
)




