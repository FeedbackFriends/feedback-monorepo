package dk.example.feedback.config

import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import dk.example.feedback.controller.OffsetDateTimeDeserializer
import dk.example.feedback.controller.OffsetDateTimeSerializer
import java.time.OffsetDateTime
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class JacksonConfig {
    @Bean
    fun javaTimeModule(): JavaTimeModule? {
        val javaTimeModule = JavaTimeModule()
        javaTimeModule.addDeserializer(OffsetDateTime::class.java, OffsetDateTimeDeserializer())
        javaTimeModule.addSerializer(OffsetDateTime::class.java, OffsetDateTimeSerializer())
        return javaTimeModule
    }
}
