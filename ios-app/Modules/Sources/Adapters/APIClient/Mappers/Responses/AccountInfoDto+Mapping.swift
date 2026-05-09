import Domain
import OpenAPI

public extension AccountInfo {
    init(_ dto: Components.Schemas.AccountInfoDto) {
        self.init(
            name: dto.name,
            email: dto.email,
            phoneNumber: dto.phoneNumber
        )
    }
}
