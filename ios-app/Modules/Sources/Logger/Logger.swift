import Foundation

public enum Logger {
    
    private static let core = _LoggerCore()
    
    public static func setup(logClients: [LoggingClient]) {
        Task { await core.setup(logClients) }
    }
    
    public static func log(
        _ level: SeverityLevel,
        _ message: String,
        _ context: CustomStringConvertible? = nil,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
        let contextString = context.flatMap { String(describing: $0) }
        Task {
            await core.log(level, message, contextString, file, function, line)
        }
    }
    
    public static func debug(
        _ message: String,
        _ context: CustomStringConvertible? = nil,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
        log(.debug, message, context, file, function, line)
    }
}

private actor _LoggerCore {
    private var clients: [LoggingClient] = []
    
    func setup(_ clients: [LoggingClient]) { self.clients = clients }
    
    func log(
        _ level: SeverityLevel,
        _ message: String,
        _ context: String?,
        _ file: String,
        _ function: String,
        _ line: Int
    ) {
        for client in clients {
            client.log(
                level: level,
                message: message,
                context: context,
                file: file,
                function: function,
                line: line
            )
        }
    }
}
