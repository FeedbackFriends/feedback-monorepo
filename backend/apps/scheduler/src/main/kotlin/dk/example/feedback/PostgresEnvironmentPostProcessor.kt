package dk.example.feedback

import org.springframework.boot.SpringApplication
import org.springframework.boot.env.EnvironmentPostProcessor
import org.springframework.core.Ordered
import org.springframework.core.env.ConfigurableEnvironment
import org.springframework.core.env.MapPropertySource

class PostgresEnvironmentPostProcessor : EnvironmentPostProcessor, Ordered {
    override fun postProcessEnvironment(
        environment: ConfigurableEnvironment,
        application: SpringApplication,
    ) {
        if (environment.containsProperty("spring.datasource.url")) {
            return
        }

        val host = environment.getProperty("POSTGRES_HOST")
        val database = environment.getProperty("POSTGRES_DB")
        val user = environment.getProperty("POSTGRES_USER")
        val password = environment.getProperty("POSTGRES_PASSWORD")

        if (listOf(host, database, user, password).all { it.isNullOrBlank() }) {
            return
        }

        if (host.isNullOrBlank() || database.isNullOrBlank() || user.isNullOrBlank() || password == null) {
            error("Set POSTGRES_HOST, POSTGRES_DB, POSTGRES_USER, and POSTGRES_PASSWORD together.")
        }

        val port = environment.getProperty("POSTGRES_PORT") ?: "5432"
        val properties = mapOf(
            "spring.datasource.url" to "jdbc:postgresql://$host:$port/$database",
            "spring.datasource.username" to user,
            "spring.datasource.password" to password,
        )

        environment.propertySources.addFirst(
            MapPropertySource("postgresDatasource", properties)
        )
    }

    override fun getOrder(): Int = Ordered.HIGHEST_PRECEDENCE
}
