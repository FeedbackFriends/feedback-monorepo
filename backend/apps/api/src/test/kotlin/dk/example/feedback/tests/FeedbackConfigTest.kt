package dk.example.feedback.tests

import dk.example.feedback.config.FeedbackConfig
import kotlin.test.Test
import kotlin.test.assertFailsWith

class FeedbackConfigTest {

    @Test
    fun `throws when admin emails are missing and test admin endpoints are disabled`() {
        assertFailsWith<IllegalStateException> {
            FeedbackConfig(
                firebaseApiKey = "test-key",
                firebaseServiceAccountJsonB64 = "",
                enableTestAdminEndpoints = false,
                adminEmails = emptyList(),
            )
        }
    }
}
