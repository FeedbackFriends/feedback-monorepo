package dk.example.feedback.config

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.web.SecurityFilterChain

@Configuration
@ConditionalOnProperty(
    name = ["feedback.features.security.enabled"],
    havingValue = "false",
)
@EnableWebSecurity
class SecurityDisabledConfig {

    @Bean
    fun permissiveFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .csrf { it.disable() }
            .authorizeHttpRequests { it.anyRequest().permitAll() }

        return http.build()
    }
}
