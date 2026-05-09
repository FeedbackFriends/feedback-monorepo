import Domain
import OpenAPI

public extension Bootstrap {
    init(_ bootstrap: Components.Schemas.BootstrapDto) {
        let role: Role? = switch bootstrap.role {
        case .some("Participant"):
            .participant
        case .some("Manager"):
            .manager
        default:
            nil
        }

        self.init(
            participantEvents: .init(uniqueElements: bootstrap.participantSessions.map(ParticipantSessionDto.init)),
            managerData: bootstrap.managerData.map(ManagerData.init),
            accountInfo: .init(bootstrap.accountInfo),
            role: role
        )
    }
}
