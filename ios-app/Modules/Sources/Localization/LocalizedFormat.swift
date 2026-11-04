import Foundation

public extension L10n {
    enum Format {
        public static func integer(_ value: Int) -> String {
            value.formatted(.number.locale(locale))
        }

        public static func dayMonth(_ value: Date, timeZone: TimeZone = .autoupdatingCurrent) -> String {
            value.formatted(Date.FormatStyle(locale: locale, timeZone: timeZone).day().month())
        }

        public static func sessionDate(
            start: Date,
            durationMinutes: Int,
            timeZone: TimeZone = .autoupdatingCurrent
        ) -> String {
            if durationMinutes == 1440 {
                return String(appStrings: .sessionAllDayDate(date(start, timeZone: timeZone)))
            }
            let end = start.addingTimeInterval(TimeInterval(durationMinutes) * 60)
            return interval(from: start, to: end, timeZone: timeZone)
        }

        public static func number(_ value: Double, fractionDigits: Int = 1) -> String {
            value.formatted(.number.locale(locale).precision(.fractionLength(fractionDigits)))
        }

        /// Accepts a ratio, e.g. 0.42 for 42 percent.
        public static func percent(_ value: Double, fractionDigits: Int = 0) -> String {
            value.formatted(.percent.locale(locale).precision(.fractionLength(fractionDigits)))
        }

        public static func date(
            _ value: Date,
            date: Date.FormatStyle.DateStyle = .abbreviated,
            time: Date.FormatStyle.TimeStyle = .omitted,
            timeZone: TimeZone = .autoupdatingCurrent
        ) -> String {
            value.formatted(Date.FormatStyle(date: date, time: time, locale: locale, timeZone: timeZone))
        }

        public static func interval(from start: Date, to end: Date, timeZone: TimeZone = .autoupdatingCurrent) -> String {
            let formatter = DateIntervalFormatter()
            formatter.locale = locale
            formatter.timeZone = timeZone
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: start, to: end)
        }

        public static func relativeTime(_ value: Date, relativeTo reference: Date = .now) -> String {
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = locale
            formatter.unitsStyle = .full
            return formatter.localizedString(for: value, relativeTo: reference)
        }

        public static func duration(minutes: Int) -> String {
            precondition(minutes >= 0, "Duration must not be negative")
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = locale
            let formatter = DateComponentsFormatter()
            formatter.calendar = calendar
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .full
            formatter.zeroFormattingBehavior = .dropAll
            guard let result = formatter.string(from: TimeInterval(minutes) * 60) else {
                preconditionFailure("Could not format duration")
            }
            return result
        }
    }
}
