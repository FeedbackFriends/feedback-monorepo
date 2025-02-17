package dk.example.feedback

import dk.example.feedback.config.FeedbackConfig
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication

@SpringBootApplication
@EnableConfigurationProperties(FeedbackConfig::class)
class FeedbackApplication

fun main(args: Array<String>) {
	runApplication<FeedbackApplication>(*args)
}

