import Foundation

public struct EmployeeTeam: Equatable, Sendable {
    public let id: String
    public let name: String
    public let organizationName: String

    public init(id: String, name: String, organizationName: String) {
        self.id = id
        self.name = name
        self.organizationName = organizationName
    }
}

public struct EmployeeTeamRequest: Equatable, Sendable {
    public enum Status: Equatable, Sendable { case pending, rejected }
    public let id: String
    public let team: EmployeeTeam
    public let status: Status

    public init(id: String, team: EmployeeTeam, status: Status) {
        self.id = id
        self.team = team
        self.status = status
    }
}

public struct EmployeeTeamContext: Equatable, Sendable {
    public var membership: EmployeeTeam?
    public var request: EmployeeTeamRequest?
    public var isLeader: Bool

    public init(membership: EmployeeTeam? = nil, request: EmployeeTeamRequest? = nil, isLeader: Bool = false) {
        self.membership = membership
        self.request = request
        self.isLeader = isLeader
    }
}
