package dk.example.feedback.config

import jakarta.servlet.http.HttpServletRequest
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.util.matcher.AntPathRequestMatcher
import org.springframework.security.web.util.matcher.RequestMatcher
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource


@Configuration
@EnableWebSecurity
@EnableMethodSecurity
class SecurityConfig {

    private val logger = LoggerFactory.getLogger(SecurityConfig::class.java)

    @Value("\${management.server.port}")
    lateinit var managementPort: String

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration()
        configuration.allowedOrigins = listOf("*")
        configuration.allowedMethods = listOf("GET", "POST", "PUT", "DELETE")
        configuration.allowedHeaders = listOf("*")
        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/**", configuration)
        return source
    }

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .cors { it.configurationSource(corsConfigurationSource()) }
            .csrf { it.disable() }
            .authorizeHttpRequests {
                it
                    .requestMatchers(AntPathRequestMatcher("/actuator/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/admin/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/v3/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/swagger-ui/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/webjars/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/**")).authenticated()
                    // The actuator endpoints runs on a different port, and must never be exposed to the internet,
                    // security is disabled for management, because kubernetes will invoke the health endpoint
                    .requestMatchers(ManagementPortMatcher(managementPort)).permitAll()
            }.oauth2ResourceServer { resourceServer ->
                resourceServer.jwt { serverConfigurer ->
                    serverConfigurer.jwtAuthenticationConverter(jwtAuthenticationConverter())
                }
            }
        return http.build()
    }

    fun jwtAuthenticationConverter(): JwtAuthenticationConverter {
        val converter = JwtAuthenticationConverter()
        converter.setJwtGrantedAuthoritiesConverter { jwt ->
            val roles = jwt.getClaimAsStringList("role") ?: emptyList()
            logger.debug("Extracted roles: {}", roles)
            roles.map { SimpleGrantedAuthority(it) }
        }
        return converter
    }

    /**
     * A matcher that compares the port number of a request
     */
    class ManagementPortMatcher(private val port: String) : RequestMatcher {

        override fun matches(request: HttpServletRequest): Boolean {
            return request.localPort == port.toInt()
        }
    }
}


//@RestController
//@Tag(name = "Test")
//@RequestMapping("/test")
//class TestController() {
//
//    @GetMapping("/protected")
//    @PreAuthorize("hasAuthority('Organizer') or hasAuthority('Participant')")
//    fun protectedEndpoint(): String {
//        return "Access granted"
//    }
//
//    @GetMapping("/authenticated")

//    @PreAuthorize("isAuthenticated()")
//    fun authenticatedEndpoint(): String {
//        return "Access granted"
//    }
//}

//class MockJwtFactory(private val userId: String) {
//
//    private fun generateJwt(userId: String, role: String? = null): Jwt {
//        val now = Instant.now()
//        val jwtBuilder = Jwt.withTokenValue("mock-token-$userId")
//            .header("alg", "RS256")
//            .claim("sub", userId)
//            .issuedAt(now)
//            .expiresAt(now.plusSeconds(3600))
//
//        // If role is not null, set it as a claim
//        role?.let {
//            // store a list of role strings if you plan on multiple roles
//            jwtBuilder.claim("role", it)
//        }
//
//        return jwtBuilder.build()
//    }
//
//    fun anonymousToken(): Jwt =
//        generateJwt(userId = userId, role = null)
//
//    fun participantToken(): Jwt =
//        generateJwt(userId = userId, role = "Participant")
//
//    fun organizerToken(): Jwt =
//        generateJwt(userId = userId, role = "Organizer")
//}


//
//
//@SpringBootTest(
//    classes = [FeedbackApplication::class]
//)
//@AutoConfigureMockMvc
//class AdminControllerIntegrationTest(
//    @Autowired private val mockMvc: MockMvc
//) {
//
//    private val jwtFactory = MockJwtFactoryFirebase("hello")
//
//    @Test
//    fun test2() {
//        mockMvc.get("/test/authenticated") {
//            header("Authorization", "Bearer ${jwtFactory.anonymousToken(mockMvc).firebaseResponse.idToken}")
//        }.andExpect {
//            status { isEqualTo(200) }
//        }
//    }
//
//    @Test
//    fun test3() {
//        mockMvc.get("/test/authenticated") {
//            header("Authorization", "Bearer ${jwtFactory.organizerToken(mockMvc).firebaseResponse.idToken}")
//        }.andExpect {
//            status { isEqualTo(200) }
//        }
//    }
//
//    @Test
//    fun test4() {
//        mockMvc.get("/test/authenticated") {
//            header("Authorization", "Bearer ${jwtFactory.participantToken(mockMvc).firebaseResponse.idToken}")
//        }.andExpect {
//            status { isEqualTo(200) }
//        }
//    }
//
//    @Test
//    fun test1() {
//        mockMvc.get("/test/protected") {
//            header("Authorization", "Bearer ${jwtFactory.anonymousToken(mockMvc).token}")
//        }.andExpect {
//            status { isEqualTo(403) }
//        }
//    }
//
//    @Test
//    fun test5() {
//        mockMvc.get("/test/protected") {
//            header("Authorization", "Bearer ${jwtFactory.participantToken(mockMvc).token}")
//        }.andExpect {
//            status { isOk() }
//        }
//    }
//
//    val token = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImJjNDAxN2U3MGE4MWM5NTMxY2YxYjY4MjY4M2Q5OThlNGY1NTg5MTkiLCJ0eXAiOiJKV1QifQ.eyJyb2xlIjoiT3JnYW5pemVyIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2ZlZWRiYWNrMi1hNGRkOSIsImF1ZCI6ImZlZWRiYWNrMi1hNGRkOSIsImF1dGhfdGltZSI6MTc0MTYzMjI3OCwidXNlcl9pZCI6ImtYTmJrUFFnWk5kNXlPNVRWU1JKWGFGc0w2NDIiLCJzdWIiOiJrWE5ia1BRZ1pOZDV5TzVUVlNSSlhhRnNMNjQyIiwiaWF0IjoxNzQxNjg2NTEzLCJleHAiOjE3NDE2OTAxMTMsImVtYWlsIjoibmljb2xhaWRhbTk2QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTA2NjA4ODE3Mzk2OTU1NDAyNzU2Il0sImVtYWlsIjpbIm5pY29sYWlkYW05NkBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19.n609NaJDWWsulgcg-NiXF8jtg0jp5pzy3tepuVZkDWZVp7LMoMpS4yuHkkV2EZaKzYkD7Jas7ytzMB6iqAdViLgXPg_qf0xS8gARaHQOcouEch2ZRnwZTHeQ7-YgWovNyyAY0zhmCV-VsPeyUNzSZpGO2q5QcbB9nrF6d6jM8j_ZPylFYKquykYP85ZXvT_vB30oTRFPyZym5aL7kC2WK1bxNtzUsCdv71diNAF0te9pxG9UKtoT-7aBWW0lWm3SKcoRdJ5NKTbOndQ7OB8j2S4yoyyidhv7PdKC1cfdASeQVVi9zDeffkGG08UVlYNT4VeXaAK5_aw9FZGYOnsrbQ"
//
//    @Test
//    fun test6_realToken() {
//        mockMvc.get("/test/protected") {
//            header("Authorization", "Bearer $token")
//        }.andExpect {
//            status { isOk() }
//            content { string("Access granted") }
//        }
//    }
////
////    @Test
////    fun testRealisticJwt() {
////        mockMvc.get("/test/protected") {
////            with(jwt().jwt(jwtFactory.generateRealisticJwt()))
////        }.andExpect {
////            status { isOk() }
////            content { string("Access granted") }
////        }
////    }
//}
