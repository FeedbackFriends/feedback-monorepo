package dk.example.feedback.config

import dk.example.feedback.model.error.ApiError
import dk.example.feedback.model.error.DomainCode
import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.media.Content
import io.swagger.v3.oas.models.media.MediaType
import io.swagger.v3.oas.models.media.Schema
import io.swagger.v3.oas.models.media.StringSchema
import io.swagger.v3.oas.models.responses.ApiResponse
import io.swagger.v3.oas.models.security.SecurityRequirement
import io.swagger.v3.oas.models.security.SecurityScheme
import org.springdoc.core.customizers.OpenApiCustomizer
import org.springframework.boot.info.BuildProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.beans.factory.ObjectProvider

@Configuration
class OpenApiConfig(
    private val buildPropertiesProvider: ObjectProvider<BuildProperties>,
) {

    @Bean
    fun swagger(): OpenAPI {
        val securitySchemeName = "bearerAuth"
        val version = buildPropertiesProvider.getIfAvailable()?.version ?: "dev"
        val (_, commitHash) = version.split("-", limit = 2).let {
            it.first() to it.getOrElse(1) { "unknown" }
        }
        return OpenAPI()
            .info(
                io.swagger.v3.oas.models.info.Info()
                    .title("Feedback API")
                    .version(version)
                    .description(
                        """
                        API documentation for Lets Grow application.

                        [Link to GitHub commit](https://github.com/FeedbackFriends/feedback-backend/commit/$commitHash)
                        """.trimIndent()
                    )
            )
            .addSecurityItem(SecurityRequirement().addList(securitySchemeName))
            .components(
                Components()
                    .addSecuritySchemes(
                        securitySchemeName,
                        SecurityScheme()
                            .name(securitySchemeName)
                            .type(SecurityScheme.Type.HTTP)
                            .scheme("bearer")
                            .bearerFormat("JWT"),
                    ),
            )
    }


    @Bean
    fun customizeGlobalResponses(): OpenApiCustomizer {

        val domainCodeSchema = StringSchema().apply {
            enum = DomainCode.entries.map { it.name }
        }

        return OpenApiCustomizer { openApi ->

            openApi.components.addSchemas("ApiError", Schema<Any>()
                .addProperty("timestamp", StringSchema())
                .addProperty("message", StringSchema())
                .addProperty("domainCode", domainCodeSchema)
                .addProperty("exceptionType", StringSchema())
                .addProperty("path", StringSchema())

            )

            openApi.paths.forEach { (_, pathItem) ->
                pathItem. readOperations().forEach { operation ->
                    val apiErrorSchema = Schema<ApiError>().`$ref`("#/components/schemas/ApiError")
                    val errorContent = Content().addMediaType(
                        "application/json", MediaType().schema(apiErrorSchema)
                    )
                    operation.responses.addApiResponse("500", ApiResponse().description("Internal Server Error").content(errorContent))
                }
            }
        }
    }
}
