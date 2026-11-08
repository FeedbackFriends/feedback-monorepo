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
private func catalogProductContact(kind: ProductContactKind, retry: Bool = false) -> some View {
    var state = ProductContact.State(kind: kind, submissionID: PreviewCatalogFixtures.id(70))
    if kind == .bugReport {
        state.message = "Når jeg åbner aktivitetslisten, vises indholdet ikke efter opdatering."
        state.expectedBehavior = "Jeg forventede at se mine aktiviteter igen."
        state.contactEmail = "anna@example.com"
    }
    if retry {
        state.error = URLError(.notConnectedToInternet).localized
    }
    return ScreenCatalogContainerView {
        ProductContactView(store: Store(initialState: state) { EmptyReducer() })
    }
}

// Screenshot: Product feedback uses the shared emoji control and accepts comment-only input.
#Preview("product-contact.feedback") { catalogProductContact(kind: .productFeedback) }

// Screenshot: Bug report has required description and optional expected behavior/contact email.
#Preview("product-contact.bug-report") { catalogProductContact(kind: .bugReport) }

// Screenshot: Network failure retains the bug report and offers safe retry.
#Preview("product-contact.retry") { catalogProductContact(kind: .bugReport, retry: true) }

@MainActor
private func catalogProductContactConfirmation() -> some View {
    var state = ProductContact.State(kind: .bugReport, submissionID: PreviewCatalogFixtures.id(70))
    state.receipt = .init(id: state.submissionID, receivedAt: PreviewCatalogFixtures.now)
    return ScreenCatalogContainerView {
        ProductContactView(store: Store(initialState: state) { EmptyReducer() })
    }
}

#Preview("product-contact.confirmation") { catalogProductContactConfirmation() }

@MainActor
private func catalogSettingsManager() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = false
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

// Screenshot: Owner settings after removing unused communication controls.
#Preview("settings.manager") {
    catalogSettingsManager()
}

@MainActor
private func catalogSettingsSaving() -> some View {
    ScreenCatalogContainerView {
        let state = {
            var state = ProfileSettings.State(accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = true
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
            var state = ProfileSettings.State(accountInfo: PreviewCatalogFixtures.account)
            state.isLoading = false
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

// Screenshot: Main screen.
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

// BEGIN GENERATED SNAPSHOT CATALOG
// Generated by scripts/ios/screen-catalog.py --generate. Do not edit this section.
@MainActor
enum MoreFeatureScreenSnapshotCatalog {
    static var samples: [ScreenSnapshotSample] {
        [
            .init(id: "product-contact.feedback", size: CGSize(width: 402, height: 874)) {
                catalogProductContact(kind: .productFeedback)
            },
            .init(id: "product-contact.bug-report", size: CGSize(width: 402, height: 874)) {
                catalogProductContact(kind: .bugReport)
            },
            .init(id: "product-contact.retry", size: CGSize(width: 402, height: 874)) {
                catalogProductContact(kind: .bugReport, retry: true)
            },
            .init(id: "settings.manager", size: CGSize(width: 402, height: 874)) {
                catalogSettingsManager()
            },
            .init(id: "edit-profile.populated", size: CGSize(width: 402, height: 874)) {
                catalogEditProfilePopulated()
            }
        ]
    }
}
// END GENERATED SNAPSHOT CATALOG
#endif
