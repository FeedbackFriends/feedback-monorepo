import ActivityFeature
import MoreFeature
import DesignSystem
import SwiftUI
import ComposableArchitecture
import FeedbackFlowFeature
import Utility
import EnterCodeFeature
import SignUpFeature

public struct TabbarView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var store: StoreOf<Tabbar>

    public init(store: StoreOf<Tabbar>) {
        self.store = store
    }
    
    public var body: some View {
        let joinEventStore = $store.scope(state: \.destination?.joinEvent, action: \.destination.joinEvent)
        tabView
            .task {
                store.send(.validateSelectedTab)
                await self.store.send(.tabbarLifecyle(.onTask)).finish()
            }
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .active:
                    store.send(.tabbarLifecyle(.enterForeground))
                case .background:
                    store.send(.tabbarLifecyle(.enterBackground))
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
            .onChange(of: store.bootstrap.role) { _, _ in
                store.send(.validateSelectedTab)
            }
            .sheet(item: joinEventStore) { store in
                JoinEventView(store: store)
                    .presentationDetents([.height(300)])
            }
            .sheet(isPresented: $store.isProfilePresented) {
                profileSheet
            }
            .animation(.bouncy, value: store.bootstrap)
            .banner(unwrapping: store.tabbarLifecyle.bannerState)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .alert($store.scope(state: \.initialiseFeedback.destination?.alert, action: \.initialiseFeedback.destination.alert))
            .fullScreenCover(
                item: $store.scope(
                    state: \.initialiseFeedback.destination?.feedbackFlowCoordinator,
                    action: \.initialiseFeedback.destination.feedbackFlowCoordinator
                )
            ) { store in
                FeedbackFlowCoordinatorView(
                    store: store,
                    principalToolbarItem: {
                        store.withState { state in
                            Text(state.title)
                                .captionTextStyle()
                                .foregroundStyle(Color.themeText)
                        }
                    }
                )
            }
    }
}

private extension TabbarView {
    var isManager: Bool {
        if case .manager = store.bootstrap.account {
            return true
        }
        return false
    }
    
    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            SwiftUI.Tab(value: Tab.feedback) {
                NavigationStack {
                    EnterCodeView(store: store.scope(state: \.enterCode, action: \.enterCode))
                        .toolbar { profileToolbarItem }
                }
            } label: {
                Image.letsGrowIconTab
                Text("Giv feedback")
            }

            SwiftUI.Tab("Aktiviteter", systemImage: "rectangle.stack", value: Tab.activities) {
                if isManager {
                    ActivityListView(
                        store: store.scope(state: \.activities, action: \.activities),
                        onProfileButtonTap: { store.send(.toolbar(.profileButtonTap)) }
                    )
                } else {
                    SignUpView(
                        store: store.scope(state: \.signUp, action: \.signUp),
                        onProfileButtonTap: { store.send(.toolbar(.profileButtonTap)) }
                    )
                }
            }
            .badge(isManager ? store.bootstrap.managerUnseenResponses : 0)
        }
        .background(LetsGrowLandingGradient())
    }

    var profileSheet: some View {
        NavigationStack {
            List {
                MoreSectionView(
                    store: store.scope(state: \.moreSection, action: \.moreSection)
                )
                    .listRowBackground(Color.themeSurface)
            }
            .scrollContentBackground(.hidden)
            .background(LetsGrowLandingGradient())
            .tint(Color.themeText)
            .accountSectionDestinations(
                store: store.scope(state: \.accountSection, action: \.accountSection),
                isDeleteAccountLoading: store.deleteAccount.deleteAccountInFlight
            )
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        store.isProfilePresented = false
                    }
                    .accessibilityIdentifier("profile_close_button")
                }
                profileSettingsToolbarItem
            }
            .alert($store.scope(state: \.deleteAccount.destination?.alert, action: \.deleteAccount.destination.alert))
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    var profileToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Profil", systemImage: "person.crop.circle") {
                store.send(.toolbar(.profileButtonTap))
            }
            .accessibilityIdentifier("profile_button")
        }
    }

    var profileSettingsToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                store.send(.accountSection(.settingsButtonTap))
            } label: {
                Image.settings
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .foregroundStyle(Color.themeText)
            .accessibilityLabel("Indstillinger")
            .accessibilityIdentifier("profile_settings_button")
        }
    }

}

#if DEBUG
extension TabbarView {
    /// Render the real profile sheet without native presentation lifecycle leaking between previews.
    var screenCatalogProfileSheet: some View { profileSheet }
}
#endif
