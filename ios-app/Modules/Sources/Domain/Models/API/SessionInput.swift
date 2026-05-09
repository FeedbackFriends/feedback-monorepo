import Foundation

public struct SessionInput: Equatable, Sendable {
    public var activityId: UUID
    public var date: Date
    public var durationInMinutes: Int
    public var location: String?

    public init(
        activityId: UUID,
        date: Date,
        durationInMinutes: Int,
        location: String? = nil
    ) {
        self.activityId = activityId
        self.date = date
        self.durationInMinutes = durationInMinutes
        self.location = location
    }
}
