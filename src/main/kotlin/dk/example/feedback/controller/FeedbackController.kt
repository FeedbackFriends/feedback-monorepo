package dk.example.feedback.controller

import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.dto.SubmitFeedbackResponseDto
import dk.example.feedback.model.payloads.SendFeedbackInput
import dk.example.feedback.model.payloads.StartFeedbackSessionInput
import dk.example.feedback.service.FeedbackService
import org.springframework.web.bind.annotation.*
import org.springframework.security.access.prepost.PreAuthorize

@RestController
@RequestMapping(ControllerPaths.FeedbackUrl)
class FeedbackController(val feedbackService: FeedbackService) {

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/start")
    fun startFeedbackSession(
        @RequestBody startFeedbackSessionInput: StartFeedbackSessionInput,
    ): FeedbackSessionDto {
        return feedbackService.startSession(pinCode = startFeedbackSessionInput.pinCode)
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/submit")
    fun sendFeedback(@RequestBody input: SendFeedbackInput): SubmitFeedbackResponseDto {
        return feedbackService.sendFeedback(
            feedbackInputList = input.feedback,
            pinCode = input.pinCode,
        )
    }
}

