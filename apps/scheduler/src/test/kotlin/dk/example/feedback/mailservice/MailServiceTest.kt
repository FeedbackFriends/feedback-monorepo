package dk.example.feedback.mailservice

import dk.example.feedback.service.CalendarInviteParser
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.io.InputStream
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.ZonedDateTime

class MailServiceTest {

    @Test
    fun `parses first invite`() {
        val invite = CalendarInviteParser.parse(resource("invite_1.ics"))

        assertThat(invite.summary).contains("Visma Talk")
        assertThat(invite.attendees).containsExactly("nicolai.dam@visma.com")
        assertThat(invite.start).isEqualTo(
            ZonedDateTime.of(LocalDateTime.of(2025, 10, 16, 10, 0), ZoneId.of("Europe/Oslo")),
        )
        assertThat(invite.description).contains("Welcome to")
    }

    @Test
    fun `parses second invite`() {
        val invite = CalendarInviteParser.parse(resource("invite_2.ics"))

        assertThat(invite.summary).isEqualTo("Gennemgå previousVoucherIdSuggestion")
        assertThat(invite.attendees).containsExactly(
            "lennart.kristensen@visma.com",
            "nicolai.dam@visma.com",
            "jacob.nordfalk@visma.com",
        )
        assertThat(invite.start).isEqualTo(
            ZonedDateTime.of(LocalDateTime.of(2025, 12, 10, 10, 15), ZoneId.of("Europe/Oslo")),
        )
        assertThat(invite.description).contains("Google Meet")
    }

    private fun resource(name: String): InputStream =
        requireNotNull(this::class.java.classLoader.getResourceAsStream(name)) { "Missing resource $name" }
}
