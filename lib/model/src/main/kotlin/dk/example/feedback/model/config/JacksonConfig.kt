//package dk.example.feedback.model.config
//
//import com.fasterxml.jackson.databind.ObjectMapper
//import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
//import com.fasterxml.jackson.module.kotlin.KotlinModule
//import java.time.OffsetDateTime
//import org.springframework.context.annotation.Bean
//import org.springframework.context.annotation.Configuration
//
//@Configuration
//class JacksonConfig {
//    @Bean
//    fun javaTimeModule(): JavaTimeModule? {
//        val javaTimeModule = JavaTimeModule()
//        javaTimeModule.addDeserializer(OffsetDateTime::class.java, OffsetDateTimeDeserializer())
//        javaTimeModule.addSerializer(OffsetDateTime::class.java, OffsetDateTimeSerializer())
//        return javaTimeModule
//    }
//    @Bean
//    fun objectMapper(): ObjectMapper {
//        return ObjectMapper()
//            .registerModule(KotlinModule.Builder().build())
//    }
//}
