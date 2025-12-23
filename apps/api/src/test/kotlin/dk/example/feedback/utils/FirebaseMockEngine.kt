package dk.example.feedback.utils

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.firebase.FirebaseUser
import dk.example.feedback.model.enumerations.Role

class FirebaseMockEngine(userId: String) : FirebaseService {


    private var user: FirebaseUser? = FirebaseUser(
        displayName = null,
        email = null,
        phoneNumber = null,
        photoUrl = null
    )

    private var role: Role? = null

    override fun configure(configFilePath: String) {}

    override fun pushFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>) {
        println("Mock sending ${feedbackReceivedNotifications.size} notifications")
    }

    override fun getUser(userId: String): FirebaseUser {
        return user!!
    }

    override fun deleteUser(userId: String) {
        user = null
        role = null
    }

    override fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        user = FirebaseUser(
            displayName = displayName,
            email = email,
            phoneNumber = phoneNumber,
            photoUrl = null
        )
    }

    override fun setRole(userId: String, requestedRole: Role?) {
        println("🚀 Before setting role: Current role = $role, New role = $requestedRole")
        role = requestedRole
        println("✅ After setting role: Current role = $role")
    }

//    suspend fun getToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor {
//        val token = mutex.withLock {
//            when (role) {
//                Role.Participant -> mockJwtFactory.participantToken()
//                Role.Organizer -> mockJwtFactory.organizerToken()
//                else -> mockJwtFactory.anonymousToken()
//            }
//        }
//        println("Getting token for role $role")
//        return token
//    }

}
