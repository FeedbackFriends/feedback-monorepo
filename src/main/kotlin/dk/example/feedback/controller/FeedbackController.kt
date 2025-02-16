package dk.example.feedback.controller

import dk.example.feedback.model.dto.FeedbackSessionDto
import dk.example.feedback.model.dto.SubmitFeedbackResponseDto
import dk.example.feedback.model.payloads.SendFeedbackInput
import dk.example.feedback.model.payloads.StartFeedbackSessionInput
import dk.example.feedback.service.FeedbackService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
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

