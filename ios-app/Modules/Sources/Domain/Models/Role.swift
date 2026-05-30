public enum Role: String, Equatable, Sendable {
    case participant, manager
    
    public var localized: String {
        switch self {
        case .participant:
            "Deltager"
        case .manager:
            "Mødeejer"
        }
    }
}
