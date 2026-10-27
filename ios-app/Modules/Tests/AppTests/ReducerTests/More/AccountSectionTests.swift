@testable import MoreFeature
import Testing
import ComposableArchitecture
import Domain

@MainActor
struct AccountSectionTests {
    @Test
    func `Settings opens profile settings with the current account`() async {
        let bootstrap: Bootstrap = .mock()
        let store = TestStore(initialState: AccountSection.State(bootstrap: .init(value: bootstrap))) {
            AccountSection()
        }

        await store.send(.settingsButtonTap) {
            $0.destination = .profileSettings(ProfileSettings.State(
                role: bootstrap.role,
                accountInfo: bootstrap.accountInfo
            ))
        }
    }

    @Test
    func `Profile settings opens the account editor`() async {
        let bootstrap: Bootstrap = .mock()
        let store = TestStore(initialState: ProfileSettings.State(
            role: bootstrap.role,
            accountInfo: bootstrap.accountInfo
        )) {
            ProfileSettings()
        }

        await store.send(.updateProfileButtonTap) {
            $0.destination = .modifyAccount(ModifyAccount.State(
                nameInput: bootstrap.accountInfo.name ?? "",
                emailInput: bootstrap.accountInfo.email ?? "",
                phoneNumberInput: bootstrap.accountInfo.phoneNumber ?? ""
            ))
        }
    }
}
