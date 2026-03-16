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
                    Text(name ?? "Not found")
                        .font(.montserratRegular, 16)
                    HStack {
                        Image.personCircleFill
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color(.systemGray2))
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email ?? "Not found")
                            Text(phoneNumber ?? "Not found")
                        }
                        .font(.montserratMedium, 10)
                        Spacer()
                        Image.chevronRight
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(10)
                            .foregroundStyle(Color(.systemGray2))
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

            Section {
                Toggle(
                    isOn: Binding(
                        get: { store.isOrganizerModeEnabled },
                        set: { store.send(.organizerModeToggleChanged($0)) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Organizer mode")
                            .font(.montserratSemiBold, 15)
                            .foregroundStyle(Color.themeText)
                        Text("Create and manage your own feedback sessions.")
                            .font(.montserratRegular, 12)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .tint(Color.themePrimaryAction)
                .disabled(store.isLoading)

                if store.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.themePrimaryAction))
                        Text("Updating preference...")
                            .font(.montserratRegular, 12)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
            } footer: {
                Text("Turn this off if you only want to give feedback when invited. You can still join with a PIN.")
                    .font(.montserratRegular, 12)
                    .foregroundStyle(Color.themeTextSecondary)
            }

            Section {
                Toggle(
                    isOn: Binding(
                        get: { store.isInAppNotificationsEnabled },
                        set: { store.send(.inAppNotificationsToggleChanged($0)) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("In-app notifications")
                            .font(.montserratSemiBold, 15)
                            .foregroundStyle(Color.themeText)
                        Text("Get timely reminders and updates about your events.")
                            .font(.montserratRegular, 12)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .tint(Color.themePrimaryAction)
                .disabled(store.isLoading)

                Toggle(
                    isOn: Binding(
                        get: { store.isEmailEventsEnabled },
                        set: { store.send(.emailEventsToggleChanged($0)) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email events")
                            .font(.montserratSemiBold, 15)
                            .foregroundStyle(Color.themeText)
                        Text("Receive event-related updates in your inbox.")
                            .font(.montserratRegular, 12)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .tint(Color.themePrimaryAction)
                .disabled(store.isLoading)
            } header: {
                Text("Communication preferences")
                    .sectionHeaderStyle()
            }

            if let logoutButtonTap {
                Section {
                    Button {
                        logoutButtonTap()
                    } label: {
                        listElementView(image: .moreSectionPortraitAndArrowRight, label: "Logout")
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
                            label: "Delete account",
                            isLoading: isDeleteAccountLoading
                        )
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .navigationTitle("Settings")
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
                    role: .manager,
                    accountInfo: .init(name: "Jane Doe", email: "jane@doe.com", phoneNumber: "+45 12 34 56 78")
                ),
                reducer: {
                    ProfileSettings()
                }
            )
        )
    }
}
