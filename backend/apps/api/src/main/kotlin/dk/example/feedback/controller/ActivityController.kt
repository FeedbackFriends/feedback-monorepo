package dk.example.feedback.controller

import dk.example.feedback.dto.ActivityDto
import dk.example.feedback.dto.ActivityInput
import dk.example.feedback.model.enumerations.RoleConstants
import dk.example.feedback.service.ActivityService
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@Tag(name = "Activity")
@RequestMapping("/activity")
class ActivityController(
    private val activityService: ActivityService,
) {
    @PostMapping
    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    fun createActivity(
        @RequestBody input: ActivityInput,
        @AuthenticationPrincipal principal: Jwt
    ): ActivityDto {
        return activityService.createActivity(input = input, jwt = principal)
    }

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @PutMapping("/{activityId}")
    fun updateActivity(
        @RequestBody activityInput: ActivityInput,
        @PathVariable activityId: UUID,
        @AuthenticationPrincipal principal: Jwt
    ): ActivityDto {
        return activityService.updateActivity(activityId = activityId, input = activityInput, jwt = principal)
    }

    @PreAuthorize("hasAuthority('${RoleConstants.MANAGER}')")
    @DeleteMapping("/{activityId}")
    fun deleteActivity(@PathVariable activityId: UUID, @AuthenticationPrincipal principal: Jwt) {
        activityService.deleteActivity(activityId = activityId, jwt = principal)
    }
}
