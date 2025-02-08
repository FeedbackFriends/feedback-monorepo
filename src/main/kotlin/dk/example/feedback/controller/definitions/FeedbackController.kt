package dk.example.feedback.controller.definitions

import ControllerPaths
import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.dto.SubmitFeedbackResponseDto
import dk.example.feedback.model.payloads.SendFeedbackInput
import dk.example.feedback.model.payloads.StartFeedbackSessionInput
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@Tag(name = "Feedback", description = "Handles feedback sessions")
@RequestMapping(ControllerPaths.FeedbackUrl)
interface FeedbackController {

    @Operation(summary = "Start a feedback session")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/start")
    fun startFeedback(@RequestBody startFeedbackSessionInput: StartFeedbackSessionInput): FeedbackSessionDto

    @Operation(summary = "Submit feedback")
    @PreAuthorize("isAuthenticated()")
    @PostMapping("/submit")
    fun submitFeedback(@RequestBody input: SendFeedbackInput): SubmitFeedbackResponseDto

}
