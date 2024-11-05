//package dk.example.feedback.controller
//
//import com.google.firebase.auth.ActionCodeSettings
//import com.google.firebase.auth.FirebaseAuth
//import com.google.firebase.auth.FirebaseAuthException
//import com.google.firebase.auth.UserRecord
//import dk.example.feedback.service.UserService
//import org.springframework.web.bind.annotation.*
//import java.util.UUID
//
//@RestController
//@RequestMapping("/organization")
//class OrganizationController(val service: UserService) {
//
//    data class EmailDto(
//        val subject: String,
//        val body: String,
//    )
//
//    @PostMapping("/edit_invitation_email")
//    fun editInvitationEmail(@RequestBody email: EmailDto) {
//        println("Editing invitation email")
//    }
//
//    @PostMapping("/invite")
//    fun invite(@RequestBody emails: List<String>): String {
//
//        val actionCodeSettings = ActionCodeSettings.builder()
//        .setIosBundleId("com.example.ios")
//        .setAndroidPackageName("com.example.android")
//        .setAndroidInstallApp(true)
//        .setHandleCodeInApp(true)
//        .setAndroidMinimumVersion("12")
//        .setUrl("https://www.example.com/finishSignUp")
//        .setDynamicLinkDomain("example.page.link")
//        .build()
//
//        for (email in emails) {
//            try {
//                val link = FirebaseAuth.getInstance().generateSignInWithEmailLink(
//                    email,
//                    actionCodeSettings
//                )
//                sendEmail(email, link)
//                return link
//            } catch (e: FirebaseAuthException) {
//                println("Error generating email link: " + e.message)
//            }
//        }
//        return ""
//    }
//
//    // implement sendCustomEmail(email, link)
//    private fun sendEmail(email: String, link: String) {
//        println("Sending email to $email with link $link")
//    }
//}