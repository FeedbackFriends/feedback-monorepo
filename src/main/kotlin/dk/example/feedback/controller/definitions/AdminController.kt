package dk.example.feedback.controller.definitions

import ControllerPaths
import dk.example.feedback.service.Claim
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@Tag(name = "Admin", description = "Admin operations for user and organization management")
@RequestMapping(ControllerPaths.AdminUrl)
interface AdminController {

    @Operation(summary = "Get all Firebase users", description = "Retrieves all users from Firebase Auth")
    @GetMapping("/all-users")
    fun allUsers(): List<com.google.firebase.auth.ExportedUserRecord>

    @Operation(summary = "Set user claims", description = "Assigns custom claims to a Firebase user")
    @PostMapping(path = ["/user-claims/{uid}"])
    fun setUserClaims(@PathVariable uid: String, @RequestBody requestedClaims: Claim)
}
