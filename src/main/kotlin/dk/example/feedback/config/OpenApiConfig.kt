package dk.example.feedback.config

import dk.example.feedback.model.error.ApiError
import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.media.Content
import io.swagger.v3.oas.models.media.Schema
import io.swagger.v3.oas.models.media.StringSchema
import io.swagger.v3.oas.models.responses.ApiResponse
import io.swagger.v3.oas.models.security.SecurityRequirement
import io.swagger.v3.oas.models.security.SecurityScheme
import org.springdoc.core.customizers.OpenApiCustomizer
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig(private val feedbackConfig: FeedbackConfig) {

    @Bean
    fun swagger(): OpenAPI {
        val securitySchemeName = "bearerAuth"
        return OpenAPI()
            .info(
                io.swagger.v3.oas.models.info.Info()
                    .title("Feedback API")
                    .version(feedbackConfig.version)
                    .description("API documentation for the Feedback service")
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
        return OpenApiCustomizer { openApi ->

            openApi.components.addSchemas("ApiError", Schema<Any>()
                .addProperty("stackTrace", StringSchema())
                .addProperty("message", StringSchema())
                .addProperty("timestamp", StringSchema())
            )

            openApi.paths.forEach { (_, pathItem) ->
                pathItem. readOperations().forEach { operation ->
                    operation.responses.addApiResponse("401", ApiResponse().description("Unauthorized"))
                    operation.responses.addApiResponse("403", ApiResponse().description("Forbidden"))
                    val apiErrorSchema = Schema<ApiError>().`$ref`("#/components/schemas/ApiError")
                    val errorContent = Content().addMediaType(
                        "application/json", io.swagger.v3.oas.models.media.MediaType().schema(apiErrorSchema)
                    )
                    operation.responses.addApiResponse("500", ApiResponse().description("Internal Server Error").content(errorContent))
                }
            }
        }
    }
}


