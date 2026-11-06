package dk.example.feedback.payloads

import dk.example.feedback.model.enumerations.SupportSubmissionKind
import dk.example.feedback.model.enumerations.Emoji
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.util.UUID

data class SupportClientMetadataInput(
    @field:NotBlank @field:Size(max = 100) val appVersion: String,
    @field:NotBlank @field:Size(max = 100) val appBuild: String,
    @field:NotBlank @field:Size(max = 100) val osVersion: String,
)

data class SupportSubmissionInput(
    val id: UUID,
    val kind: SupportSubmissionKind,
    val rating: Emoji? = null,
    @field:Size(max = 5000) val message: String? = null,
    @field:Size(max = 5000) val expectedBehavior: String? = null,
    @field:Email @field:Size(max = 254) val contactEmail: String? = null,
    @field:Valid val metadata: SupportClientMetadataInput,
)
