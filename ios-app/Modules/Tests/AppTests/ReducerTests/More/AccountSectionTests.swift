@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct AccountSectionTests {
    
    @Test
    func `Tap on update profile button`() async {
        let session: Session = .mock()
        let store = TestStore(initialState: AccountSection.State(session: .init(value: session))) {
            AccountSection()
        }
        await store.send(.updateProfileButtonTap) {
            $0.destination = .modifyAccount(ModifyAccount.State(
                nameInput: session.accountInfo.name ?? "",
                emailInput: session.accountInfo.email ?? "",
                phoneNumberInput: session.accountInfo.phoneNumber ?? ""
            ))
        }
    }
    
    @Test
    func `Change user button tap`() async {
        let store = TestStore(initialState: AccountSection.State(session: .init(value: .mock()))) {
            AccountSection()
        }
        await store.send(.changeUserTypeButtonTap) {
            $0.destination = .changeUserType(ChangeUserType.State(selectedUserType: .manager))
        }
    }
}
