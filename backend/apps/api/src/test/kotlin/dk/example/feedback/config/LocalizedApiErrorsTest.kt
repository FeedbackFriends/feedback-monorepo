package dk.example.feedback.config

import dk.example.feedback.controller.ControllerAdvisor
import dk.example.feedback.model.error.DomainCode
import dk.example.feedback.model.exceptions.DomainException
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.http.HttpStatus
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.header
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

class LocalizedApiErrorsTest {
    @Test
    fun `language negotiation respects quality regional fallback exclusions and defaults`() {
        val cases = mapOf(
            null to "da", "" to "da", "de, fr;q=0.5" to "da", "not valid!" to "da",
            "en-GB" to "en", "da-DK" to "da", "da;q=0.2,en;q=0.9" to "en",
            "de;q=1,da-DK;q=0.8,en;q=0.7" to "da", "en;q=0,da;q=0.8" to "da",
            "en;q=1,*;q=0" to "en", "*;q=0.5,en;q=0" to "da",
        )
        cases.forEach { (header, expected) -> assertEquals(expected, LocalizedApiErrors.language(header), header) }
    }

    @Test
    fun `every domain error has safe copy in both languages and preserves diagnostics separately`() {
        for (language in listOf("da", "en")) {
            for (code in DomainCode.entries) {
                val request = MockHttpServletRequest("GET", "/example")
                request.addHeader("Accept-Language", language)
                val response = LocalizedApiErrors.response(
                    IllegalStateException("sensitive diagnostic"), request, ErrorResponseConfig.resolve(code), code,
                )
                val error = requireNotNull(response.body)
                assertTrue(requireNotNull(error.userTitle).isNotBlank())
                val userMessage = requireNotNull(error.userMessage)
                assertTrue(userMessage.isNotBlank())
                assertFalse(userMessage.contains("sensitive"))
                assertEquals(code, error.domainCode)
                assertEquals("sensitive diagnostic", error.message)
                assertEquals(language, response.headers.getFirst("Content-Language"))
                assertTrue(response.headers.vary.contains("Accept-Language"))
            }
        }
    }

    @Test
    fun `MVC business validation and unexpected failures share the localized envelope`() {
        val mvc = MockMvcBuilders.standaloneSetup(ErrorController())
            .setMessageConverters(MappingJackson2HttpMessageConverter(JacksonConfig().objectMapper()))
            .setControllerAdvice(ControllerAdvisor()).build()
        mvc.perform(get("/test-errors/domain").param("code", "PINCODE_NOT_FOUND").header("Accept-Language", "en-GB"))
            .andExpect(status().isNotFound)
            .andExpect(header().string("Content-Language", "en"))
            .andExpect(jsonPath("$.userTitle").value("Invalid PIN code"))
            .andExpect(jsonPath("$.domainCode").value("PINCODE_NOT_FOUND"))
        mvc.perform(get("/test-errors/domain").param("code", "invalid").header("Accept-Language", "da"))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.userTitle").value("Ugyldige oplysninger"))
        val unexpected = LocalizedApiErrors.response(
            IllegalStateException("sensitive diagnostic"), MockHttpServletRequest("GET", "/example"), HttpStatus.INTERNAL_SERVER_ERROR,
        )
        assertEquals("Noget gik galt. Prøv igen.", unexpected.body?.userMessage)
    }

    @RestController
    class ErrorController {
        @GetMapping("/test-errors/domain")
        fun domain(@RequestParam code: DomainCode): Nothing = throw object : DomainException(code, "sensitive diagnostic") {}
    }
}
