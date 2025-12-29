package dk.example.feedback.controller

import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.service.ActivityService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Activity")
@RequestMapping("/activity")
class ActivityController(val activityService: ActivityService) {
    @GetMapping("/mark-activity-as-seen")
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun markActivityAsSeen(
        @AuthenticationPrincipal principal: Jwt
    ) {
        return activityService.markActivityAsSeen(jwt = principal)
    }
}
