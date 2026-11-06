import Localization
import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ProfileSectionView: View {
    let name: String?
    let email: String?
    let phoneNumber: String?
    let updateProfileButtonTap: () -> Void

    var body: some View {
        Section {
            Button {
                updateProfileButtonTap()
            } label: {
                VStack(alignment: .leading) {
                    Text(name ?? String(appStrings: .profileMissingValue))
                        .bodyTextStyle()
                    HStack {
                        ProfileAvatarView(name: name, size: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email ?? String(appStrings: .profileMissingValue))
                            Text(phoneNumber ?? String(appStrings: .profileMissingValue))
                        }
                        .captionTextStyle()
                        Spacer()
                        Image.chevronRight
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(10)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .foregroundStyle(Color.themeText)
            }
        }
    }
}

public struct ProfileSettingsView: View {

    @Bindable var store: StoreOf<ProfileSettings>
    let logoutButtonTap: (() -> Void)?
    let deleteAccountButtonTap: (() -> Void)?
    let isDeleteAccountLoading: Bool

    public init(
        store: StoreOf<ProfileSettings>,
        logoutButtonTap: (() -> Void)? = nil,
        deleteAccountButtonTap: (() -> Void)? = nil,
        isDeleteAccountLoading: Bool = false,
    ) {
        self.store = store
        self.logoutButtonTap = logoutButtonTap
        self.deleteAccountButtonTap = deleteAccountButtonTap
        self.isDeleteAccountLoading = isDeleteAccountLoading
    }

    public var body: some View {
        List {
            ProfileSectionView(
                name: store.accountInfo.name,
                email: store.accountInfo.email,
                phoneNumber: store.accountInfo.phoneNumber,
                updateProfileButtonTap: {
                    store.send(.updateProfileButtonTap)
                }
            )

            if let logoutButtonTap {
                Section {
                    Button {
                        logoutButtonTap()
                    } label: {
                        listElementView(image: .moreSectionPortraitAndArrowRight, label: String(appStrings: .commonLogout))
                    }
                } 
            }

            if let deleteAccountButtonTap {
                Section {
                    Button {
                        deleteAccountButtonTap()
                    } label: {
                        listElementView(
                            image: .moreSectionTrash,
                            label: String(appStrings: .accountDeleteAction),
                            isLoading: isDeleteAccountLoading
                        )
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .navigationTitle(String(appStrings: .commonSettings))
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.modifyAccount,
                action: \.destination.modifyAccount
            )
        ) { modifyAccountStore in
            ModifyAccountView(store: modifyAccountStore)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview {
    NavigationStack {
        ProfileSettingsView(
            store: .init(
                initialState: .init(
                    accountInfo: .init(name: "Jane Doe", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
                ),
                reducer: {
                    ProfileSettings()
                }
            )
        )
    }
}
