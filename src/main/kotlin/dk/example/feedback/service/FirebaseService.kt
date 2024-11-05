package dk.example.feedback.service

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserRecord
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.Message
import com.google.firebase.messaging.Notification
import org.springframework.stereotype.Service

enum class Claim {
    Manager,
    Participant
}

interface FirebaseService {
    fun sendNotifications(messages: List<Message>)
    fun getUser(userId: String): User
    fun deleteUser(userId: String)
    fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?)
    fun setUserClaims(userId: String, requestedClaim: Claim?)

    data class User(
        val displayName: String?,
        val phoneNumber: String?,
        val email: String?,
    )

    data class Message(
        val title: String,
        val body: String,
        val fcmToken: String,
        val data: Map<String, String>
    )
}

@Service
class FirebaseServiceLive: FirebaseService {

    override fun sendNotifications(messages: List<FirebaseService.Message>) {
        FirebaseMessaging.getInstance().sendEachAsync(
            messages.map {
                Message.builder()
                    .setNotification(
                        Notification.builder()
                            .setTitle(it.title)
                            .setBody(it.body)
                            .build()
                    )
                    .putAllData(it.data)
                    .setToken(it.fcmToken)
                    .build()
            }
        )
    }

    override fun getUser(userId: String): FirebaseService.User {

        val userRecord = FirebaseAuth.getInstance().getUser(userId)
        // if email is null (user is anonymous) then return null
        return FirebaseService.User(
            displayName = userRecord.displayName,
            phoneNumber = userRecord.phoneNumber,
            email = userRecord.email
        )
    }

    override fun deleteUser(userId: String) {
        FirebaseAuth.getInstance().deleteUser(userId)
    }

    override fun updateUser(userId: String, email: String?, displayName: String?, phoneNumber: String?) {
        FirebaseAuth.getInstance().updateUser(
            UserRecord.UpdateRequest(userId)
                .setEmail(email)
                .setDisplayName(displayName)
                .setPhoneNumber(phoneNumber)
        )
    }

    override fun setUserClaims(userId: String, requestedClaim: Claim?) {
        val requestedClaims: MutableList<String> = mutableListOf()
        requestedClaim?.let { requestedClaims.add(it.name) }
        val claims = mapOf(
            "custom_claims" to requestedClaims
        )
        FirebaseAuth.getInstance().setCustomUserClaimsAsync(userId,  claims)
    }
}