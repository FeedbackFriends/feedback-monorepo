package dk.example.feedback

import dk.example.feedback.config.FeedbackConfig
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@EnableConfigurationProperties(FeedbackConfig::class)
@EnableScheduling
class FeedbackApplication

fun main(args: Array<String>) {
	runApplication<FeedbackApplication>(*args)
}

