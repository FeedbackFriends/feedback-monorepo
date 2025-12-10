package dk.example.feedback.mailservice

import dk.example.feedback.service.CalendarInviteParser
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.io.InputStream
import java.time.LocalDateTime
import java.time.ZoneId

class MailServiceTest {

    @Test
    fun `parses google invite`() {
        val invite = CalendarInviteParser.parse(resource("invite_1.ics"))

        val expectedStart = LocalDateTime.of(2025, 10, 16, 10, 0)
            .atZone(ZoneId.of("Europe/Oslo"))
            .toOffsetDateTime()

        assertThat(invite.title).contains("Visma Talk")
        assertThat(invite.managerEmail).isEqualTo("visma.com_43d5pqqnaqi5p0co1d5nt0317g@group.calendar.google.com")
        assertThat(invite.attendingEmails).containsExactly("nicolai.dam@visma.com")
        assertThat(invite.date).isEqualTo(expectedStart)
        assertThat(invite.durationInMinutes).isEqualTo(60)
        assertThat(invite.agenda).contains("Welcome to")
        assertThat(invite.location).contains("stream")
    }

    @Test
    fun `parses short google meet invite`() {
        val invite = CalendarInviteParser.parse(resource("invite_2.ics"))

        val expectedStart = LocalDateTime.of(2025, 12, 10, 10, 15)
            .atZone(ZoneId.of("Europe/Oslo"))
            .toOffsetDateTime()

        assertThat(invite.title).isEqualTo("Gennemgå previousVoucherIdSuggestion")
        assertThat(invite.managerEmail).isEqualTo("lennart.kristensen@visma.com")
        assertThat(invite.attendingEmails).containsExactly(
            "nicolai.dam@visma.com",
            "jacob.nordfalk@visma.com",
        )
        assertThat(invite.date).isEqualTo(expectedStart)
        assertThat(invite.durationInMinutes).isEqualTo(15)
        assertThat(invite.agenda).contains("Google Meet")
        assertThat(invite.location).contains("meet.google.com")
    }

    @Test
    fun `parses google invite with attendees`() {
        val invite = CalendarInviteParser.parse(resource("invite_google.ics"))

        val expectedStart = LocalDateTime.of(2025, 12, 11, 10, 30)
            .atZone(ZoneId.of("Europe/Copenhagen"))
            .toOffsetDateTime()

        assertThat(invite.title).isEqualTo("Cool møde")
        assertThat(invite.managerEmail).isEqualTo("nicolaidam96@gmail.com")
        assertThat(invite.attendingEmails).containsExactly("contact@damofficial.com")
        assertThat(invite.date).isEqualTo(expectedStart)
        assertThat(invite.durationInMinutes).isEqualTo(60)
        assertThat(invite.agenda).contains("Google Meet")
        assertThat(invite.location).contains("meet.google.com")
    }

    @Test
    fun `parses teams invite with windows timezone`() {
        val invite = CalendarInviteParser.parse(resource("invite_teams.ics"))

        val expectedLocal = LocalDateTime.of(2025, 10, 27, 9, 30)

        assertThat(invite.title).contains("17538 - BLR 110179 / SR 110279 POI events must be resend")
        assertThat(invite.managerEmail).isEqualTo("twd@tdcnet.dk")
        assertThat(invite.attendingEmails.map { it.lowercase() }).contains(
            "dlm@tdcnet.dk",
            "nicolaidam96@gmail.com",
            "nabg@nuuday.dk",
            "htr@nuuday.dk",
            "sjjd@nuuday.dk",
            "mif@nuuday.dk",
        ).doesNotContain("twd@tdcnet.dk")
        assertThat(invite.date.toLocalDateTime()).isEqualTo(expectedLocal)
        assertThat(invite.durationInMinutes).isEqualTo(30)
        assertThat(invite.location).contains("Microsoft Teams")
        assertThat(invite.agenda).contains("Let us see what is missing")
    }

    private fun resource(name: String): InputStream =
        requireNotNull(this::class.java.classLoader.getResourceAsStream(name)) { "Missing resource $name" }
}
