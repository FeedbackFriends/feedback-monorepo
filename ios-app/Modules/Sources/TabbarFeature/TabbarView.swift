import ActivityFeature
import MoreFeature
import DesignSystem
import SwiftUI
import ComposableArchitecture
import FeedbackFlowFeature
import Utility
import EnterCodeFeature

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
                await self.store.send(.tabbarLifecyle(.onTask)).finish()
                resetSelectedTabIfNeeded()
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
                resetSelectedTabIfNeeded()
            }
            .sheet(item: joinEventStore) { store in
                JoinEventView(store: store)
                    .presentationDetents([.height(300)])
            }
            .animation(.bouncy, value: store.bootstrap)
            .banner(unwrapping: store.tabbarLifecyle.bannerState)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .alert($store.scope(state: \.initialiseFeedback.destination?.alert, action: \.initialiseFeedback.destination.alert))
            .alert($store.scope(state: \.deleteAccount.destination?.alert, action: \.deleteAccount.destination.alert))
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
            NavigationStack {
                EnterCodeView(store: store.scope(state: \.enterCode, action: \.enterCode))
            }
            .tabItem {
                Image.letsGrowIconTab
                Text("Svar")
            }
            .tag(Tab.feedback)
            
            if isManager {
                ActivityListView(
                    store: store.scope(
                        state: \.managerEvents,
                        action: \.managerEvents
                    )
                )
                    .tabItem {
                        Label("Aktiviteter", systemImage: "calendar")
                    }
                .badge(managerUnseenResponses)
                .tag(Tab.activities)
            }
            
            NavigationStack {
                List {
                    MoreSectionView(store: store.scope(state: \.moreSection, action: \.moreSection))
                        .listRowBackground(
                            Color.themeSurface
                        )
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
                    profileSettingsToolbarItem
                }
            }
            .tabItem {
                Image.personCropCircle
                Text("Profil")
            }
            .tag(Tab.more)
        }
        .background(LetsGrowLandingGradient())
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
        }
    }

    var managerUnseenResponses: Int {
        store.bootstrap.managerUnseenResponses
    }

    func resetSelectedTabIfNeeded() {
        guard !isManager else { return }
        guard store.selectedTab == .activities else { return }
        store.selectedTab = .feedback
    }
}
