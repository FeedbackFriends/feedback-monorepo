package dk.example.feedback.dto

import dk.example.feedback.model.enumerations.ActivityRunMode
import dk.example.feedback.payloads.QuestionInput
import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Manager request payload for creating or updating an activity.")
data class ActivityInput(
    @field:Schema(description = "Activity title shown in manager and participant views.")
    val title: String,
    val agenda: String?,
    @field:Schema(description = "Ordered list of activity questions.")
    val questions: List<QuestionInput>,
    @field:Schema(description = "Run mode controlling event participation behavior.")
    val runMode: ActivityRunMode,
    val invitedEmails: List<String> = emptyList(),
    val sendEmails: Boolean,
)
