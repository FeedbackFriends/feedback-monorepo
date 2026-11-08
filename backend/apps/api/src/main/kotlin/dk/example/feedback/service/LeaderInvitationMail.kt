package dk.example.feedback.service

import dk.example.feedback.config.FeedbackConfig
import dk.example.feedback.model.team.LeaderInvitation
import org.springframework.beans.factory.ObjectProvider
import org.springframework.mail.MailException
import org.springframework.mail.SimpleMailMessage
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.stereotype.Service
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

@Service
class LeaderInvitationMail(private val senders: ObjectProvider<JavaMailSender>, private val config: FeedbackConfig) {
    fun send(invitation: LeaderInvitation) {
        val sender = senders.ifAvailable
        if (sender == null || config.invitationFrom.isBlank())
            throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Invitation email unavailable")
        val message = SimpleMailMessage().apply {
            setFrom(config.invitationFrom)
            setTo(invitation.email)
            subject = "Du er inviteret som teamleder i Lets Grow"
            text = "Du er inviteret som teamleder. Log ind med denne e-mail, og acceptér invitationen:\n\n" +
                "${config.appUrl.trimEnd('/')}/leader-invite/${invitation.code}\n\n" +
                "Invitationen gælder i syv dage. Hvis du ikke forventede invitationen, kan du ignorere den."
        }
        try { sender.send(message) } catch (_: MailException) {
            throw ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Invitation email failed; retry")
        }
    }
}
