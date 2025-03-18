package dk.example.feedback.controller

import dk.example.feedback.dto.FeedbackSessionDto
import dk.example.feedback.dto.SubmitFeedbackResponseDto
import dk.example.feedback.payloads.SendFeedbackInput
import dk.example.feedback.payloads.StartFeedbackSessionInput
import dk.example.feedback.service.FeedbackService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Feedback")
@RequestMapping("/feedback")
class FeedbackController(val feedbackService: FeedbackService) {

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/start")
    fun startFeedbackSession(
        @RequestBody startFeedbackSessionInput: StartFeedbackSessionInput,
        @AuthenticationPrincipal principal: Jwt
    ): FeedbackSessionDto {
        return feedbackService.startSession(pinCode = startFeedbackSessionInput.pinCode, jwt = principal)
    }

    @PreAuthorize("isAuthenticated()")
    @PostMapping("/submit")
    suspend fun sendFeedback(
        @RequestBody input: SendFeedbackInput,
        @AuthenticationPrincipal principal: Jwt
    ): SubmitFeedbackResponseDto {
        return feedbackService.sendFeedback(
            feedbackInputList = input.feedback,
            pinCode = input.pinCode,
            jwt = principal
        )
    }
}

