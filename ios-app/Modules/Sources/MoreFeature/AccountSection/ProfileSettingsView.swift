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
                        .bodyTextStyle()
                    HStack {
                        Image.personCircleFill
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.themeTextSecondary)
                            .background(Color.themeSurfaceSecondary)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email ?? "Not found")
                            Text(phoneNumber ?? "Not found")
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

            Section {
                Toggle(
                    isOn: Binding(
                        get: { store.isOrganizerModeEnabled },
                        set: { store.send(.organizerModeToggleChanged($0)) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mødeejer")
                            .rowTitleTextStyle()
                            .foregroundStyle(Color.themeText)
                        Text("Opret aktiviteter og følg feedback over tid.")
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .tint(Color.themePrimaryAction)
                .disabled(store.isLoading)

                if store.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.themePrimaryAction))
                        Text("Opdaterer indstilling...")
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
            } footer: {
                Text("Slå fra, hvis du kun vil svare på feedback med en PIN-kode.")
                    .supportingTextStyle()
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
                        Text("Notifikationer i appen")
                            .rowTitleTextStyle()
                            .foregroundStyle(Color.themeText)
                        Text("Få påmindelser og opdateringer om dine møder.")
                            .supportingTextStyle()
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
                        Text("Møder på mail")
                            .rowTitleTextStyle()
                            .foregroundStyle(Color.themeText)
                        Text("Modtag mødeopdateringer i din indbakke.")
                            .supportingTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .tint(Color.themePrimaryAction)
                .disabled(store.isLoading)
            } header: {
                SectionHeaderView("Kommunikation", horizontalPadding: 0)
            }

            if let logoutButtonTap {
                Section {
                    Button {
                        logoutButtonTap()
                    } label: {
                        listElementView(image: .moreSectionPortraitAndArrowRight, label: "Log ud")
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
                            label: "Slet konto",
                            isLoading: isDeleteAccountLoading
                        )
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .navigationTitle("Indstillinger")
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
