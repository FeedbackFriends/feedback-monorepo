import Domain
import OpenAPI

extension EmployeeTeam {
    init(_ dto: Components.Schemas.TeamInfo) {
        self.init(id: dto.id, name: dto.name, organizationName: dto.organizationName)
    }
}

extension EmployeeTeamContext {
    init(_ dto: Components.Schemas.TeamContext) {
        let request: EmployeeTeamRequest? = dto.request.flatMap { request in
            switch request.status {
            case .pending: EmployeeTeamRequest(id: request.id, team: .init(request.team), status: .pending)
            case .rejected: EmployeeTeamRequest(id: request.id, team: .init(request.team), status: .rejected)
            case .approved, .canceled: nil
            }
        }
        self.init(membership: dto.membership.map(EmployeeTeam.init), request: request, isLeader: !dto.managedTeams.isEmpty)
    }
}
