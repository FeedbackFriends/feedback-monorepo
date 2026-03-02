package dk.example.feedback.utils

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseAdminService
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.firebase.FirebaseUser
import dk.example.feedback.model.enumerations.Role

class FirebaseMockEngine(userId: String) : FirebaseService, FirebaseAdminService {

    private val users = mutableMapOf(
        userId to FirebaseUser(
            displayName = null,
            email = null,
            phoneNumber = null,
            photoUrl = null
        )
    )

    private val roles = mutableMapOf<String, Role?>()

    override fun configure(configFilePath: String) {}

    override fun pushFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>) {
        println("Mock sending ${feedbackReceivedNotifications.size} notifications")
    }

    override fun getUser(userId: String): FirebaseUser {
        return users.getOrPut(userId) {
            FirebaseUser(
                displayName = null,
                email = null,
                phoneNumber = null,
                photoUrl = null
            )
        }
    }

    override fun deleteUser(userId: String) {
        users.remove(userId)
        roles.remove(userId)
    }

    override fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        users[userId] = FirebaseUser(
            displayName = displayName,
            email = email,
            phoneNumber = phoneNumber,
            photoUrl = null
        )
    }

    override fun setRole(userId: String, requestedRole: Role?) {
        roles[userId] = requestedRole
    }

    override fun createUserIfMissing(uid: String, email: String, displayName: String) {}

    override fun createCustomToken(uid: String): String {
        return "mock-custom-token-$uid"
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
