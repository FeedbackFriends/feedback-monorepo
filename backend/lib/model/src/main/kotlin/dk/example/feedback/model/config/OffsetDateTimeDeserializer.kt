//package dk.example.feedback.model.config
//
//import com.fasterxml.jackson.core.JsonGenerator
//import com.fasterxml.jackson.core.JsonParser
//import com.fasterxml.jackson.databind.DeserializationContext
//import com.fasterxml.jackson.databind.SerializerProvider
//import com.fasterxml.jackson.databind.deser.std.StdDeserializer
//import com.fasterxml.jackson.databind.ser.std.StdSerializer
//import java.time.OffsetDateTime
//import java.time.format.DateTimeFormatter
//import java.time.temporal.ChronoUnit
//
///**
// * Custom deserializer that ensures that OffsetDateTime types are parsed correctly.
// *
// * Please note that the entire backend system is only using UTC for all date time values.
// * All the date time values in the database are stored in UTC.
// * All data that is sent to the frontend is also in UTC.
// * The frontend client is not required to send data in UTC, but it is recommended for consistency.
// * If the frontend sends an OffsetDateTime with an offset, it will be converted to UTC.
// */
//class OffsetDateTimeDeserializer : StdDeserializer<OffsetDateTime>(OffsetDateTime::class.java) {
//
//    override fun deserialize(jsonParser: JsonParser, ctxt: DeserializationContext): OffsetDateTime {
//        return OffsetDateTime.parse(jsonParser.readValueAs(String::class.java))
//    }
//}
//
///**
// * Custom serializer that ensures that OffsetDateTime types are formatted correctly.
// */
//class OffsetDateTimeSerializer : StdSerializer<OffsetDateTime>(OffsetDateTime::class.java) {
//
//    override fun serialize(value: OffsetDateTime, gen: JsonGenerator, provider: SerializerProvider) {
//        gen.writeString(value.toFormattedString())
//    }
//}
//
///**
// * Convert and format OffsetDateTime to String.
// * This uses the ISO_INSTANT date time format.
// * Truncated to seconds meaning that there will be no milliseconds.
// * Example of format: "2022-06-23T17:20:12Z"
// */
//fun OffsetDateTime.toFormattedString(): String {
//    return DateTimeFormatter.ISO_INSTANT.format(
//        this.truncatedTo(ChronoUnit.SECONDS),
//    )
//}
//
