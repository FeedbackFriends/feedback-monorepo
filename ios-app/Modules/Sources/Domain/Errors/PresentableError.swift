import Foundation

public struct PresentableError: Equatable {
    public let title: String
    public let message: String
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
