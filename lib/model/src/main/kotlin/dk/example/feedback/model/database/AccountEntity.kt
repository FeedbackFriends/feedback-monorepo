package dk.example.feedback.model.database

data class AccountEntity(
    val id: String, //  Provided by firebase uid in idToken
    val fcmToken: String?,
    val name: String?,
    val email: String?,
    val phoneNumber: String?,
    val ratingPrompted: Boolean,
)




