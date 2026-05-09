package dk.example.feedback.controller

import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.service.NotificationHistoryService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "NotificationHistory")
@RequestMapping("/notification-history")
class NotificationHistoryController(
    private val notificationHistoryService: NotificationHistoryService,
) {

    @GetMapping("/mark-as-seen")
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun markNotificationHistoryAsSeen(
        @AuthenticationPrincipal principal: Jwt,
    ) {
        notificationHistoryService.markNotificationHistoryAsSeen(jwt = principal)
    }
}
