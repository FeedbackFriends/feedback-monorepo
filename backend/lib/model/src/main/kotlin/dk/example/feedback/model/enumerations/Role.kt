package dk.example.feedback.model.enumerations

import com.fasterxml.jackson.annotation.JsonCreator
import com.fasterxml.jackson.annotation.JsonValue

object RoleConstants {
    const val MANAGER = "Manager"
}

sealed class Role(val value: String) {
    object Manager : Role(RoleConstants.MANAGER)

    @JsonValue
    override fun toString(): String = value

    companion object {
        @JsonCreator
        @JvmStatic
        fun fromString(value: String): Role? {
            return when (value) {
                RoleConstants.MANAGER -> Manager
                else -> null
            }
        }
    }
}
