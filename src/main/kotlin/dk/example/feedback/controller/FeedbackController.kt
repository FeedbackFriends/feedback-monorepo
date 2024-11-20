package dk.example.feedback.controller

import dk.example.feedback.model.db_models.FeedbackEntity
import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.service.FeedbackService
import org.springframework.web.bind.annotation.*
import java.security.Principal
import java.util.UUID
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt

@RestController
@RequestMapping(ControllerPaths.FeedbackUrl)
class FeedbackController(val feedbackService: FeedbackService) {

    data class StartFeedbackSession(
        val pinCode: String,
    )

    @PostMapping("/start")
    fun startFeedbackSession(
        @RequestBody startFeedbackSession: StartFeedbackSession,
    ): FeedbackSessionDto {
        return feedbackService.startSession(pinCode = startFeedbackSession.pinCode)
    }

    data class SendFeedback(
        val feedback: List<FeedbackEntity>,
        val pinCode: String,
    )

    data class SendFeedbackResponse(
        val shouldPresentRatingPrompt: Boolean,
    )

    @PostMapping("/submit")
    fun sendFeedback(@RequestBody input: SendFeedback): SendFeedbackResponse {
        return feedbackService.sendFeedback(
            feedback = input.feedback,
            pinCode = input.pinCode,
        )
    }
}