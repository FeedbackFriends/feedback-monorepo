package dk.example.feedback.utils

import dk.example.feedback.firebase.FeedbackReceivedNotification
import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.firebase.FirebaseUser
import dk.example.feedback.model.enumerations.Role
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class FirebaseMockEngine(userId: String) : FirebaseService {

    private val mutex = Mutex()

    private var user: FirebaseUser? = FirebaseUser(
        displayName = null,
        email = null,
        phoneNumber = null,
        photoUrl = null
    )

    private var role: Role? = null
    private val mockJwtFactory = MockJwtFactory(userId = userId!!)

    override fun configure(configFilePath: String) {}

    override suspend fun sendFeedbackReceivedNotifications(feedbackReceivedNotifications: List<FeedbackReceivedNotification>) {
        println("Mock sending ${feedbackReceivedNotifications.size} notifications")
    }

    override suspend fun getUser(userId: String): FirebaseUser {
        return mutex.withLock { user!! }
    }

    override suspend fun deleteUser(userId: String) {
        mutex.withLock {
            user = null
            role = null
        }
    }

    override suspend fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        mutex.withLock {
            user = FirebaseUser(
                displayName = displayName,
                email = email,
                phoneNumber = phoneNumber,
                photoUrl = null
            )
        }
    }

    override suspend fun setRole(userId: String, requestedRole: Role?) {
        mutex.withLock {
            println("🚀 Before setting role: Current role = $role, New role = $requestedRole")
            role = requestedRole
            println("✅ After setting role: Current role = $role")
        }
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
