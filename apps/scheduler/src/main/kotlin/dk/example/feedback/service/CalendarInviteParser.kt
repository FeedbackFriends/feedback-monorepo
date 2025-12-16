package dk.example.feedback.service

import dk.example.feedback.model.enumerations.CalendarProvider
import net.fortuna.ical4j.data.CalendarBuilder
import net.fortuna.ical4j.model.Parameter
import net.fortuna.ical4j.model.Property
import net.fortuna.ical4j.model.TimeZoneRegistry
import net.fortuna.ical4j.model.TimeZoneRegistryFactory
import net.fortuna.ical4j.model.component.VEvent
import net.fortuna.ical4j.model.parameter.TzId
import net.fortuna.ical4j.model.property.Attendee
import net.fortuna.ical4j.model.property.DateProperty
import net.fortuna.ical4j.model.property.Description
import net.fortuna.ical4j.model.property.Duration
import net.fortuna.ical4j.model.property.DtEnd
import net.fortuna.ical4j.model.property.DtStart
import net.fortuna.ical4j.model.property.Location
import net.fortuna.ical4j.model.property.Organizer
import net.fortuna.ical4j.model.property.Summary
import java.io.InputStream
import java.time.Instant
import java.time.OffsetDateTime
import java.time.ZoneOffset

internal object CalendarInviteParser {
    private val builder = CalendarBuilder()
    private val timeZoneRegistry = TimeZoneRegistryFactory.getInstance().createRegistry()
    private val ignoredAttendeeEmails = setOf("feedback@letsgrow.dk")

    fun parse(inputStream: InputStream): CalendarInvite {
        val calendar = builder.build(inputStream)
        val event = calendar.components
            .filterIsInstance<VEvent>()
            .firstOrNull() ?: throw IllegalArgumentException("No VEVENT found in calendar invite")

        val prodId = calendar.getProperty<Property>(Property.PRODID)?.value
        val calendarProvider = CalendarProvider.fromProdId(prodId)

        val start = (event.getProperty(Property.DTSTART) as? DtStart)
            ?.toOffsetDateTime(timeZoneRegistry)
            ?: throw IllegalArgumentException("Missing DTSTART in calendar invite")

        val end = (event.getProperty(Property.DTEND) as? DtEnd)
            ?.toOffsetDateTime(timeZoneRegistry)

        val durationMinutes = (event.getProperty(Property.DURATION) as? Duration).toMinutes()
            ?: end?.let { java.time.Duration.between(start, it).toMinutes().toInt() }
            ?: 0

        val organizerEmail = (event.getProperty(Property.ORGANIZER) as? Organizer).email()
            ?: throw IllegalArgumentException("Missing organizer in calendar invite")

        return CalendarInvite(
            title = (event.getProperty(Property.SUMMARY) as? Summary)?.value.orEmpty(),
            agenda = (event.getProperty(Property.DESCRIPTION) as? Description)?.value,
            date = start,
            durationInMinutes = durationMinutes,
            location = (event.getProperty(Property.LOCATION) as? Location)?.value,
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
        properties.getProperties<Attendee>(Property.ATTENDEE)
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

    private fun DtStart.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        toOffsetDateTimeInternal(timeZoneRegistry)

    private fun DtEnd.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        toOffsetDateTimeInternal(timeZoneRegistry)

    private fun DtStart.toOffsetDateTimeInternal(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        (this as DateProperty).toOffsetDateTime(timeZoneRegistry)

    private fun DtEnd.toOffsetDateTimeInternal(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? =
        (this as DateProperty).toOffsetDateTime(timeZoneRegistry)

    private fun DateProperty.toOffsetDateTime(timeZoneRegistry: TimeZoneRegistry): OffsetDateTime? {
        val zone = timeZone?.let { tz ->
            runCatching { tz.toZoneId() }.getOrNull()
                ?: ZoneOffset.ofTotalSeconds(tz.getOffset(date?.time ?: System.currentTimeMillis()) / 1000)
        }
            ?: (parameters.getParameter(Parameter.TZID) as? TzId)
                ?.value
                ?.let { zoneId ->
                    timeZoneRegistry.getTimeZone(zoneId)?.let { tz ->
                        runCatching { tz.toZoneId() }.getOrNull()
                    }
                }
            ?: ZoneOffset.UTC
        val dateValue = date ?: return null
        val instant = Instant.ofEpochMilli(dateValue.time)
        return instant.atZone(zone).toOffsetDateTime()
    }
}
