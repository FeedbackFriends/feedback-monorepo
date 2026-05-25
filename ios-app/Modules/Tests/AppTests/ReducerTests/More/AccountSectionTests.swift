@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct AccountSectionTests {
    
    @Test
    func `Tap on update profile button`() async {
        let bootstrap: Bootstrap = .mock()
        let store = TestStore(initialState: AccountSection.State(bootstrap: .init(value: bootstrap))) {
            AccountSection()
        }
        await store.send(.updateProfileButtonTap) {
            $0.destination = .modifyAccount(ModifyAccount.State(
                nameInput: bootstrap.accountInfo.name ?? "",
                emailInput: bootstrap.accountInfo.email ?? "",
                phoneNumberInput: bootstrap.accountInfo.phoneNumber ?? ""
            ))
        }
    }
    
    @Test
    func `Change user button tap`() async {
        let store = TestStore(initialState: AccountSection.State(bootstrap: .init(value: .mock()))) {
            AccountSection()
        }
        await store.send(.changeUserTypeButtonTap) {
            $0.destination = .changeUserType(ChangeUserType.State(selectedUserType: .manager))
        }
    }
}
