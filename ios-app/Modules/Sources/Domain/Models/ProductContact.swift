import Foundation

public enum ProductContactKind: Equatable, Sendable {
    case productFeedback, bugReport
}

public struct SupportClientMetadata: Equatable, Sendable {
    public let appVersion: String
    public let appBuild: String
    public let osVersion: String

    public init(appVersion: String, appBuild: String, osVersion: String) {
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.osVersion = osVersion
    }
}

public struct ProductContactInput: Equatable, Sendable {
    public let id: UUID
    public let kind: ProductContactKind
    public let rating: Emoji?
    public let message: String?
    public let expectedBehavior: String?
    public let contactEmail: String?
    public let metadata: SupportClientMetadata

    public init(
        id: UUID, kind: ProductContactKind, rating: Emoji?, message: String?,
        expectedBehavior: String?, contactEmail: String?, metadata: SupportClientMetadata
    ) {
        self.id = id
        self.kind = kind
        self.rating = rating
        self.message = message
        self.expectedBehavior = expectedBehavior
        self.contactEmail = contactEmail
        self.metadata = metadata
    }
}

public struct ProductContactReceipt: Equatable, Sendable {
    public let id: UUID
    public let receivedAt: Date

    public init(id: UUID, receivedAt: Date) {
        self.id = id
        self.receivedAt = receivedAt
    }
}
