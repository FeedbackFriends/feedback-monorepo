package dk.example.feedback.config

import ControllerPaths
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.util.matcher.AntPathRequestMatcher
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource


@Configuration
@EnableWebSecurity
@EnableMethodSecurity
class SecurityConfig {

    private val logger = LoggerFactory.getLogger(SecurityConfig::class.java)

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration()
        configuration.allowedOrigins = listOf("*")
        configuration.allowedMethods = listOf("GET", "POST", "PUT")
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
                    .requestMatchers(AntPathRequestMatcher("${ControllerPaths.AdminUrl}/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/v3/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/swagger-ui/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/webjars/**")).permitAll()
                    .requestMatchers(AntPathRequestMatcher("/**")).authenticated()
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
            val roles = jwt.getClaimAsStringList("custom_claims") ?: emptyList()
            logger.debug("Extracted roles: {}", roles)
            roles.map { SimpleGrantedAuthority(it) }
        }
        return converter
    }
}
