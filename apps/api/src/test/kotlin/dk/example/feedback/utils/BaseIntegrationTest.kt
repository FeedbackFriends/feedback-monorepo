package dk.example.feedback.utils

import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import dk.example.feedback.config.SecurityConfig
import dk.example.feedback.model.enumerations.Role
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.ResultActions
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestConfig::class, SecurityConfig::class)
abstract class BaseIntegrationTest(
    @Autowired val mockMvc: MockMvc,
    @Autowired val firebaseService: FirebaseMockEngine,
) {
    protected val objectMapper = jacksonObjectMapper()
        .registerModule(JavaTimeModule())
        .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)

    protected suspend fun performSuspendingRequest(requestBuilder: MockHttpServletRequestBuilder): ResultActions {
        return mockMvc.perform(MockMvcRequestBuilders.asyncDispatch(mockMvc.perform(requestBuilder).andReturn()))
    }

    protected fun performRequest(requestBuilder: MockHttpServletRequestBuilder): ResultActions {
        return mockMvc.perform(requestBuilder)
    }

//    protected suspend fun withJwt(role: Role? = null): JwtRequestPostProcessor {
//        return jwtWithRole(firebaseService.getToken())
//    }
}
