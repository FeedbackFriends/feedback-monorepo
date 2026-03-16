import OSLog

public struct OSLogClient: LoggingClient {
    let subsystem: String
    let category: String
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }
    public func log(
        level: SeverityLevel,
        message: String,
        context: (any CustomStringConvertible)?,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logger = os.Logger(subsystem: subsystem, category: category)
        var outputString: String = "\n\(level.emoji) \(message)"
        outputString.append(contentsOf: "\nfile: \(file)")
        outputString.append(contentsOf: "\nfunction: \(function)")
        outputString.append(contentsOf: "\nline: \(line)")
        if let context = context {
            outputString.append(contentsOf: "\n\ncontext: \(context.description)")
        }
        logger.log(level: level.osLogLevel, "\(outputString)")
    }
}

extension SeverityLevel {
    var emoji: String {
        switch self {
        case .fault: return "[FAULT] 🔴"
        case .error: return "[ERROR] 🟠"
        default: return "🔵"
        }
    }
}
