package dk.example.feedback

import dk.example.feedback.mail.MailListenerProperties
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication

@SpringBootApplication
@EnableConfigurationProperties(MailListenerProperties::class)
class EmailListenerApplication

fun main(args: Array<String>) {
    runApplication<EmailListenerApplication>(*args)
}
