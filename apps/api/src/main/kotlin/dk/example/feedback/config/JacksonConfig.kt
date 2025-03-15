package dk.example.feedback.config

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.KotlinModule
import java.time.OffsetDateTime
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class JacksonConfig {
    @Bean
    fun objectMapper(): ObjectMapper {
        return ObjectMapper()
            .registerModule(KotlinModule.Builder().build())
            .registerModule(JavaTimeModule())
            .registerModule(
                SimpleModule()
                    .addDeserializer(OffsetDateTime::class.java, OffsetDateTimeDeserializer())
                    .addSerializer(OffsetDateTime::class.java, OffsetDateTimeSerializer())
            )
    }
}
