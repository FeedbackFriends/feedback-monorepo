package dk.example.feedback.model.enumerations

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue

object RoleConstants {
    const val ORGANIZER = "Organizer"
    const val PARTICIPANT = "Participant"
}

sealed class Role(val value: String) {
    object Participant : Role(RoleConstants.PARTICIPANT)
    object Organizer : Role(RoleConstants.ORGANIZER)

    @JsonValue
    override fun toString(): String = value

    companion object {
        @JsonCreator
        @JvmStatic
        fun fromString(value: String): Role? {
            return when (value) {
                RoleConstants.PARTICIPANT -> Participant
                RoleConstants.ORGANIZER -> Organizer
                else -> null
            }
        }
    }
}
