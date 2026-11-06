import Foundation
import Localization

public extension Date {
    func timeFormatted() -> String {
        return L10n.Format.date(self, date: .omitted, time: .shortened)
    }
    func dateAndYear() -> String {
        return L10n.Format.date(self)
    }
    func roundedUpcoming5Min() -> Self {
        Date(
            timeIntervalSinceReferenceDate:
                (Date.now.timeIntervalSinceReferenceDate / 300.0).rounded(.up) * 300.0
        )
    }
}

public extension Date {
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    var isAfterToday: Bool {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        
        // Include only events happening strictly after today
        return self.compare(todayEnd) != .orderedAscending
    }
    
    var isBeforeToday: Bool {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        return self < todayStart
    }
}

public extension Date {
    func timeAgo(_ locale: Locale = L10n.locale, relativeTo referenceDate: Date = .now) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = locale
        return formatter.localizedString(for: self, relativeTo: referenceDate)
    }
}
