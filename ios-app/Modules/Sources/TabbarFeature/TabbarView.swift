import FocusFeature
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
        let notificationHistoryStore = $store.scope(state: \.destination?.notificationHistory, action: \.destination.notificationHistory)
        let createActivityStore = $store.scope(
            state: \.managerEvents.destination?.createActivity,
            action: \.managerEvents.destination.createActivity
        )
        tabView
            .task {
                await self.store.send(.tabbarLifecyle(.onTask)).finish()
                resetSelectedTabIfNeeded()
            }
//            .overlay(alignment: .bottomTrailing) {
//                if shouldShowJoinFloatingActionButton {
//                    joinFloatingActionButton
//                        .padding(.trailing, 20)
//                        .padding(.bottom, 80)
//                }
//            }
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
            .onChange(of: store.session.role) { _, _ in
                resetSelectedTabIfNeeded()
            }
            .sheet(item: joinEventStore) { store in
                JoinEventView(store: store)
                    .presentationDetents([.height(300)])
            }
            .sheet(item: createActivityStore) { store in
                CreateActivityView(store: store)
            }
            .animation(.bouncy, value: store.session)
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
                                .font(.montserratSemiBold, 12)
                                .foregroundStyle(Color.themeText)
                        }
                    }
                )
            }
    }
}

private extension TabbarView {
    var isManager: Bool {
        if case .manager = store.session.account {
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
                Text("Give Feedback")
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
                        Label("My Activities", systemImage: "scope")
                    }
                .tag(Tab.events)
            }
            
            NavigationStack {
                List {
                    MoreSectionView(store: store.scope(state: \.moreSection, action: \.moreSection))
                        .listRowBackground(
                            Color.themeSurface
                        )
                }
                .scrollContentBackground(.hidden)
                .background(Color.themeBackground)
                .tint(Color.themeText)
                .accountSectionDestinations(
                    store: store.scope(state: \.accountSection, action: \.accountSection),
                    isDeleteAccountLoading: store.deleteAccount.deleteAccountInFlight
                )
                .navigationTitle("Profile")
                .toolbar {
                    profileSettingsToolbarItem
                }
                .background(Color.themeBackground)
            }
            .tabItem {
                Image.personCropCircle
                Text("Profile")
            }
            .tag(Tab.more)
        }
        
    }
    
    var participantEventsView: some View {
        ParticipantEventsView(
            store: store.scope(
                state: \.participantEvents,
                action: \.participantEvents
            )
        )
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

    var feedbackTabContent: some View {
        Group {
            participantEventsView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground.ignoresSafeArea())
    }

    var shouldShowJoinFloatingActionButton: Bool {
        store.selectedTab == .feedback
    }
    
    var joinFloatingActionButton: some View {
        Button {
            store.send(.toolbar(.joinEventButtonTap))
        } label: {
            Text("Join with PIN")
            .font(.montserratSemiBold, 15)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .foregroundStyle(Color.themeOnPrimaryAction)
            .background(Color.themePrimaryAction.gradient, in: Capsule())
        }
    }

    func resetSelectedTabIfNeeded() {
        guard !isManager else { return }
        guard store.selectedTab == .events else { return }
        store.selectedTab = .feedback
    }
}

#warning("Fix me")
//#Preview {
//    TabbarView(
//        store: StoreOf<Tabbar>.init(initialState: .init(session: .init(value: .mock()))) {
//            Tabbar()
//        }
//    )
//}
