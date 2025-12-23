package dk.example.feedback.utils

import dk.example.feedback.model.enumerations.Role
class MockJwtFactory(private val userId: String) {
    private fun buildToken(role: Role? = null): String {
        return listOfNotNull(userId, role?.value).joinToString(".")
    }

    fun anonymousToken(): String = buildToken(role = null)

    fun participantToken(): String = buildToken(role = Role.Participant)

    fun managerToken(): String = buildToken(role = Role.Manager)
}
