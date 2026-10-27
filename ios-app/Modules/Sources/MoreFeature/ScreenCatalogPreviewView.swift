#if DEBUG
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

extension MoreSection.State {
    public static var screenCatalog: Self {
        var state = Self()
        state.privacyPolicyUrl = URL(string: "https://letsgrow.dk/privacy")
        state.appStoreReviewUrl = URL(string: "https://apps.apple.com/app/id000000000")
        return state
    }
}

@MainActor
private func catalogSettingsManager() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(role: .manager, accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = false
            state.isInAppNotificationsEnabled = false
            state.isEmailEventsEnabled = false
            return state
        }()
        NavigationStack {
            ProfileSettingsView(
                store: Store(initialState: state) { EmptyReducer() },
                logoutButtonTap: {}, deleteAccountButtonTap: {}, isDeleteAccountLoading: false
            )
        }
    }
}

#Preview("settings.manager") {
    catalogSettingsManager()
}

@MainActor
private func catalogSettingsParticipant() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(role: .participant, accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = false
            state.isInAppNotificationsEnabled = false
            state.isEmailEventsEnabled = false
            return state
        }()
        NavigationStack {
            ProfileSettingsView(
                store: Store(initialState: state) { EmptyReducer() },
                logoutButtonTap: {}, deleteAccountButtonTap: {}, isDeleteAccountLoading: false
            )
        }
    }
}

#Preview("settings.participant") {
    catalogSettingsParticipant()
}

@MainActor
private func catalogSettingsAnonymous() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(role: nil, accountInfo: .init(name: nil, email: nil, phoneNumber: nil))
            state.isLoading = false
            state.isInAppNotificationsEnabled = false
            state.isEmailEventsEnabled = false
            return state
        }()
        NavigationStack {
            ProfileSettingsView(
                store: Store(initialState: state) { EmptyReducer() },
                logoutButtonTap: nil, deleteAccountButtonTap: {}, isDeleteAccountLoading: false
            )
        }
    }
}

#Preview("settings.anonymous") {
    catalogSettingsAnonymous()
}

@MainActor
private func catalogSettingsNotificationsEnabled() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(role: .manager, accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = false
            state.isInAppNotificationsEnabled = true
            state.isEmailEventsEnabled = true
            return state
        }()
        NavigationStack {
            ProfileSettingsView(
                store: Store(initialState: state) { EmptyReducer() },
                logoutButtonTap: {}, deleteAccountButtonTap: {}, isDeleteAccountLoading: false
            )
        }
    }
}

#Preview("settings.notifications-enabled") {
    catalogSettingsNotificationsEnabled()
}

@MainActor
private func catalogSettingsSaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(role: .manager, accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = true
            state.isInAppNotificationsEnabled = true
            state.isEmailEventsEnabled = true
            return state
        }()
        NavigationStack {
            ProfileSettingsView(
                store: Store(initialState: state) { EmptyReducer() },
                logoutButtonTap: {}, deleteAccountButtonTap: {}, isDeleteAccountLoading: false
            )
        }
    }
}

#Preview("settings.saving") {
    catalogSettingsSaving()
}

@MainActor
private func catalogSettingsDeletingAccount() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(role: .manager, accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = false
            state.isInAppNotificationsEnabled = false
            state.isEmailEventsEnabled = false
            return state
        }()
        NavigationStack {
            ProfileSettingsView(
                store: Store(initialState: state) { EmptyReducer() },
                logoutButtonTap: {}, deleteAccountButtonTap: {}, isDeleteAccountLoading: true
            )
        }
    }
}

#Preview("settings.deleting-account") {
    catalogSettingsDeletingAccount()
}

@MainActor
private func catalogEditProfilePopulated() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ModifyAccount.State(
                nameInput: "Anna Jensen", emailInput: "anna@example.com", phoneNumberInput: "+45 12 34 56 78"
            )
            state.isLoading = false
            return state
        }()
        ModifyAccountView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("edit-profile.populated") {
    catalogEditProfilePopulated()
}

@MainActor
private func catalogEditProfileEmpty() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ModifyAccount.State(
                nameInput: "", emailInput: "", phoneNumberInput: ""
            )
            state.isLoading = false
            return state
        }()
        ModifyAccountView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("edit-profile.empty") {
    catalogEditProfileEmpty()
}

@MainActor
private func catalogEditProfileSaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ModifyAccount.State(
                nameInput: "Anna Jensen", emailInput: "anna@example.com", phoneNumberInput: "+45 12 34 56 78"
            )
            state.isLoading = true
            return state
        }()
        ModifyAccountView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("edit-profile.saving") {
    catalogEditProfileSaving()
}

#Preview("settings.full-content", traits: .fixedLayout(width: 402, height: 1500)) {
    catalogSettingsManager()
}

#endif
