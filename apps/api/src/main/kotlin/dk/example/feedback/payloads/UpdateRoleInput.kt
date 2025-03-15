package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.Role


data class UpdateRoleInput(
    val role: Role
)
