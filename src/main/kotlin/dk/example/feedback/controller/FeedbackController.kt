package dk.example.feedback.controller

import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.payloads.SendFeedbackInput
import dk.example.feedback.service.FeedbackService
import org.springframework.web.bind.annotation.*
import org.springframework.security.access.prepost.PreAuthorize

@RestController
@RequestMapping(ControllerPaths.FeedbackUrl)
class FeedbackController(val feedbackService: FeedbackService) {

    data class StartFeedbackSession(
        val pinCode: String,
    )

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/start")
    fun startFeedbackSession(
        @RequestBody startFeedbackSession: StartFeedbackSession,
    ): FeedbackSessionDto {
        return feedbackService.startSession(pinCode = startFeedbackSession.pinCode)
    }


    @PreAuthorize("isAuthenticated()")
    @PostMapping("/submit")
    fun sendFeedback(@RequestBody input: SendFeedbackInput): SendFeedbackResponse {
        return feedbackService.sendFeedback(
            feedbackInputList = input.feedback,
            pinCode = input.pinCode,
        )
    }
}

data class SendFeedbackResponse(
    val shouldPresentRatingPrompt: Boolean,
)
