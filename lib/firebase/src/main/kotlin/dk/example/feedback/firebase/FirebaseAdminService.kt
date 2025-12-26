package dk.example.feedback.firebase

interface FirebaseAdminService {
    fun createUserIfMissing(uid: String, email: String, displayName: String)
    fun createCustomToken(uid: String): String
}
