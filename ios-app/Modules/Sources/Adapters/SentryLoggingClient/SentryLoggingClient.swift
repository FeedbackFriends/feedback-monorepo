import Sentry
import Logger

public struct SentryLoggingClient: LoggingClient {
    let minLevel: SeverityLevel

    public func log(
        level: SeverityLevel,
        message: String,
        context: (any CustomStringConvertible)?,
        file: String,
        function: String,
        line: Int
    ) {
        if level >= minLevel {
            // Capture as an event at or above the minimum level
            let event = Event()
            event.level = sentryLevel(from: level)
            event.message = SentryMessage(formatted: message)

            var extra: [String: Any] = [
                "file": file,
                "function": function,
                "line": line
            ]
            if let context = context { extra["context"] = context.description }
            event.extra = extra

            SentrySDK.capture(event: event)
            
        } else {
            // Below threshold: add a breadcrumb so it's visible with future events
            let crumb = Breadcrumb()
            crumb.level = sentryLevel(from: level)
            crumb.category = "log"
            crumb.message = message
            crumb.data = [
                "file": file,
                "function": function,
                "line": line
            ]
            if let context = context { crumb.data?["context"] = context.description }
            SentrySDK.addBreadcrumb(crumb)
        }
    }

    func onStart(deviceId: String) {
        let user = User(userId: deviceId)
        SentrySDK.setUser(user)
    }

    private func sentryLevel(from level: SeverityLevel) -> SentryLevel {
        switch level {
        case .fault: return .fatal
        case .error: return .error
        case .info: return .info
        case .debug: return .debug
        default: return .info
        }
    }
}

public extension SentryLoggingClient {
    static func create(deviceId: String, minLevel: SeverityLevel) -> SentryLoggingClient {
        let client = SentryLoggingClient(minLevel: minLevel)
        client.onStart(deviceId: deviceId)
        return client
    }
}
