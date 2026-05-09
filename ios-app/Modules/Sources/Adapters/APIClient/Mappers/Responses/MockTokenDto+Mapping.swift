import Domain
import OpenAPI

public extension MockTokenDto {
    init(_ dto: Components.Schemas.MockTokenDto) {
        self.init(token: dto.token)
    }
}
