package dk.example.feedback.ical

import dk.example.feedback.model.enumerations.CalendarProvider
import net.fortuna.ical4j.data.CalendarBuilder
import net.fortuna.ical4j.model.Parameter
import net.fortuna.ical4j.model.TimeZoneRegistry
import net.fortuna.ical4j.model.TimeZoneRegistryFactory
import net.fortuna.ical4j.model.TemporalAdapter
import net.fortuna.ical4j.model.component.CalendarComponent
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.parameter.TzId
import net.fortuna.ical4j.model.property.DateProperty
import net.fortuna.ical4j.model.property.Duration
import net.fortuna.ical4j.model.property.Organizer
import net.fortuna.ical4j.util.CompatibilityHints
import java.io.InputStream
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.temporal.Temporal

object CalendarInviteParser {
    private val builder = CalendarBuilder()
    private val timeZoneRegistry = TimeZoneRegistryFactory.getInstance().createRegistry()
    private val ignoredAttendeeEmails = setOf("feedback@letsgrow.dk")

    fun parse(inputStream: InputStream): CalendarInvite {
        CompatibilityHints.setHintEnabled(CompatibilityHints.KEY_RELAXED_PARSING, true)
        CompatibilityHints.setHintEnabled(CompatibilityHints.KEY_RELAXED_UNFOLDING, true)
        val calendar = builder.build(inputStream)
        val event = calendar.getComponents<CalendarComponent>()
            .filterIsInstance<VEvent>()
            .firstOrNull() ?: throw IllegalArgumentException("No VEVENT found in calendar invite")

        val prodId = calendar.getProperty<net.fortuna.ical4j.model.Property>(net.fortuna.ical4j.model.Property.PRODID)
            .orElse(null)
            ?.value
        val calendarProvider = CalendarProvider.fromProdId(prodId)

        val start = event.getDateTimeStart<Temporal>()
            ?.toOffsetDateTime(timeZoneRegistry)
            ?: throw IllegalArgumentException("Missing DTSTART in calendar invite")

        val end = event.getDateTimeEnd<Temporal>()
            ?.toOffsetDateTime(timeZoneRegistry)

        val durationMinutes = event.getDuration().toMinutes()
            ?: end?.let { java.time.Duration.between(start, it).toMinutes().toInt() }
            ?: 0

        val organizerEmail = event.getOrganizer().email()
            ?: throw IllegalArgumentException("Missing organizer in calendar invite")

        return CalendarInvite(
            title = event.getSummary()?.value.orEmpty(),
            agenda = event.getDescription()?.value,
            date = start,
            durationInMinutes = durationMinutes,
            location = event.getLocation()?.value,
            managerEmail = organizerEmail,
            attendingEmails = event.attendeeEmails(excludeEmail = organizerEmail),
            calendarProvider = calendarProvider,
        )
    }

    private fun Duration?.toMinutes(): Int? = this?.duration?.let {
        runCatching { java.time.Duration.from(it).toMinutes().toInt() }.getOrNull()
    }

    private fun Organizer?.email(): String? =
        this?.calAddress?.schemeSpecificPart
            ?.removePrefix("mailto:")
            ?.removePrefix("MAILTO:")
            ?.trim()
            ?.takeIf { it.isNotEmpty() }

    private fun VEvent.attendeeEmails(excludeEmail: String?): List<String> =
        getAttendees()
            .mapNotNull { attendee ->
                attendee.calAddress?.schemeSpecificPart
                    ?.removePrefix("mailto:")
                    ?.removePrefix("MAILTO:")
                    ?.trim()
                    ?.takeIf { it.isNotEmpty() }
            }.filterNot { email -> shouldIgnoreAttendee(email, excludeEmail) }

    private fun shouldIgnoreAttendee(email: String, organizerEmail: String?): Boolean {
        if (organizerEmail != null && email.equals(organizerEmail, ignoreCase = true)) {
            return true
        }
        return ignoredAttendeeEmails.any { email.equals(it, ignoreCase = true) }
    }

    private fun <T : Temporal> DateProperty<T>.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? {
        val temporal = date ?: return null
        return when (temporal) {
            is OffsetDateTime -> temporal
            is ZonedDateTime -> temporal.toOffsetDateTime()
            is LocalDateTime -> temporal.atZone(resolveZoneId(timeZoneRegistry)).toOffsetDateTime()
            is LocalDate -> temporal.atStartOfDay(resolveZoneId(timeZoneRegistry)).toOffsetDateTime()
            is Instant -> temporal.atZone(resolveZoneId(timeZoneRegistry)).toOffsetDateTime()
            else -> runCatching {
                TemporalAdapter.toLocalTime(temporal, resolveZoneId(timeZoneRegistry)).toOffsetDateTime()
            }.getOrNull()
        }
    }

    private fun DateProperty<*>.resolveZoneId(timeZoneRegistry: TimeZoneRegistry): ZoneId {
        val tzId = getParameter<TzId>(Parameter.TZID).orElse(null)
        val registryZone = tzId?.value?.let { id -> timeZoneRegistry.getTimeZone(id)?.toZoneId() }
        return registryZone ?: ZoneOffset.UTC
    }
}

data class CalendarInvite(
    val title: String,
    val agenda: String?,
    val date: OffsetDateTime,
    val durationInMinutes: Int,
    val location: String?,
    val managerEmail: String,
    val attendingEmails: List<String>,
    val calendarProvider: CalendarProvider?,
)
