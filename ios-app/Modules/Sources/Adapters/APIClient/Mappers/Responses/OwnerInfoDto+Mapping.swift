import Domain
import OpenAPI

public extension OwnerInfo {
    init(_ dto: Components.Schemas.OwnerDto) {
        self.init(
            name: dto.name,
            email: dto.email,
            phoneNumber: nil
        )
    }

    init(_ dto: Components.Schemas.OwnerInfoDto) {
        self.init(
            name: dto.name,
            email: dto.email,
            phoneNumber: dto.phoneNumber
        )
    }
}
