public protocol LoggingClient: Sendable {
    func log(
        level: SeverityLevel,
        message: String,
        context: CustomStringConvertible?,
        file: String,
        function: String,
        line: Int
    )
}
