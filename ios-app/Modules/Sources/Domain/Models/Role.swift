public enum Role: String, Equatable, Sendable {
    case manager
    
    public var localized: String {
        switch self {
        case .manager:
            "Mødeejer"
        }
    }
}
