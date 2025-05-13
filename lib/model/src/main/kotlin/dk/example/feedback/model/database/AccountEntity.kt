package dk.example.feedback.model.database

import java.util.*

data class AccountEntity(
    val id: String, //  Provided by firebase uid in idToken
    val fcmTokens: List<String>,
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
    val ratingPrompted: Boolean,
    val feedbackSessionHash: UUID,
)




