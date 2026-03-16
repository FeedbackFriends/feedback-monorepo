import EventsFeature
import EnterCodeFeature
import SwiftUI
import Foundation
import MoreFeature
import DesignSystem
import Domain
import ComposableArchitecture
import Utility
import Logger

public enum Tab: Hashable, Sendable {
    case feedback, events, more
}

public extension Tabbar.State {
    init(
        session: Shared<Session>,
        syncStatus: Shared<SyncStatus> = Shared(value: SyncStatus()),
        tabbarLifecyle: TabbarLifecycle.State,
        enterCode: EnterCode.State,
        moreSection: MoreSection.State,
        accountSection: AccountSection.State,
        selectedTab: Tab,
        initialiseFeedback: InitialiseFeedback.State,
        managerEvents: ManagerEvents.State,
        participantEvents: ParticipantEvents.State,
        deleteAccount: DeleteAccount.State,
        destination: Tabbar.Destination.State? = nil
    ) {
        self._session = session
        self._syncStatus = syncStatus
        self.tabbarLifecyle = tabbarLifecyle
        self.enterCode = enterCode
        self.moreSection = moreSection
        self.accountSection = accountSection
        self.selectedTab = selectedTab
        self.initialiseFeedback = initialiseFeedback
        self.managerEvents = managerEvents
        self.participantEvents = participantEvents
        self.deleteAccount = deleteAccount
        self.destination = destination
    }
    
    init(
        session: Shared<Session>,
        syncStatus: Shared<SyncStatus> = Shared(value: SyncStatus()),
        selectedTab: Tab = .events,
        destination: Tabbar.Destination.State? = nil,
    ) {
        self._session = session
        self._syncStatus = syncStatus
        self.enterCode = .init()
        self.selectedTab = selectedTab
        self.moreSection = .init()
        self.accountSection = .init(session: session)
        self.initialiseFeedback = .init()
        self.participantEvents = .init(session: session)
        self.deleteAccount = .init()
        self.managerEvents = .init(session: session, syncStatus: syncStatus)
        self.tabbarLifecyle = .init(session: session, syncStatus: syncStatus)
        self.destination = destination
    }
}

@Reducer
public struct Tabbar: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<AlertAction>)
        case joinEvent(JoinEvent)
        @ReducerCaseIgnored
        case activity([ActivityItems])
        public enum AlertAction: Equatable, Sendable {
            case confirmedToCreateUser
        }
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        
        @Shared public var session: Session
        @Shared public var syncStatus: SyncStatus
        var tabbarLifecyle: TabbarLifecycle.State
        var enterCode: EnterCode.State
        var moreSection: MoreSection.State
        var accountSection: AccountSection.State
        public var selectedTab: Tab
        var initialiseFeedback: InitialiseFeedback.State
        public var managerEvents: ManagerEvents.State
        var participantEvents: ParticipantEvents.State
        var deleteAccount: DeleteAccount.State
        @Presents var destination: Destination.State?
    }
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case enterCode(EnterCode.Action)
        case moreSection(MoreSection.Action)
        case accountSection(AccountSection.Action)
        case initialiseFeedback(InitialiseFeedback.Action)
        case participantEvents(ParticipantEvents.Action)
        case managerEvents(ManagerEvents.Action)
        case destination(PresentationAction<Destination.Action>)
        case toolbar(Toolbar)
        case delegate(Delegate)
        case signUpButtonTap
        case activityManagerEventButtonTap(ActivityItems)
        case tabbarLifecyle(TabbarLifecycle.Action)
        case deleteAccount(DeleteAccount.Action)
        case dismissFeedbackFlow
        public enum Toolbar: Equatable {
            case joinEventButtonTap
            case activityButtonTap
        }
        public enum Delegate: Equatable {
            case startFeedback(pinCode: PinCode)
            case navigateToSignUp
        }
    }
    
    @Dependency(\.apiClient) var apiClient
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.initialiseFeedback, action: \.initialiseFeedback) {
            InitialiseFeedback()
        }
        Scope(state: \.enterCode, action: \.enterCode) {
            EnterCode()
        }
        Scope(state: \.participantEvents, action: \.participantEvents) {
            ParticipantEvents()
        }
        Scope(state: \.managerEvents, action: \.managerEvents) {
            ManagerEvents()
        }
        Scope(state: \.accountSection, action: \.accountSection) {
            AccountSection()
        }
        Scope(state: \.moreSection, action: \.moreSection) {
            MoreSection()
        }
        Scope(state: \.tabbarLifecyle, action: \.tabbarLifecyle) {
            TabbarLifecycle()
        }
        Scope(state: \.deleteAccount, action: \.deleteAccount) {
            DeleteAccount()
        }
        Reduce { state, action in
            switch action {
             
            case .dismissFeedbackFlow:
                state.initialiseFeedback.destination = nil
                return .none
                
            case .tabbarLifecyle:
                return .none
                
            case .activityManagerEventButtonTap(let activityItem):
                state.managerEvents.destination = .eventDetail(
                    EventDetailFeature.State(
                        event: state.session.unwrappedManagerSession.managerData.managerEvents[id: activityItem.eventId]!,
                        session: state.$session
                    )
                )
                return .run { _ in
                    do {
                        try await apiClient.markEventAsSeen(activityItem.id)
                    } catch {
                        Logger.debug("Reset new feedback failed with error: \(error.localizedDescription)")
                    }
                }
                
            case .accountSection(.delegate(.navigateToSignUp)):
                return .send(.delegate(.navigateToSignUp))
                
            case .accountSection(.delegate(.deleteAccountButtonTapped)):
                return .send(.deleteAccount(.deleteAccountButtonTapped))
                
            case .accountSection:
                return .none
                
            case .destination(.presented(.alert(let alertAction))):
                switch alertAction {
                case .confirmedToCreateUser:
                    return .send(.delegate(.navigateToSignUp))
                }
                
            case .destination(.presented(.joinEvent(.delegate(.navigateToParticipantEvent(let pinCode))))):
                return .send(.participantEvents(.startFeedbackButtonTap(pinCode: pinCode)))

            case .destination:
                return .none
                
            case .binding:
                return .none
                
            case .enterCode(.delegate(.startFeedback(let pinCode))),
                    .participantEvents(.delegate(.startFeedback(let pinCode))):
                return .send(.initialiseFeedback(.startFeedback(pinCode: pinCode)))
                
            case .initialiseFeedback(.delegate(let delegateAction)):
                switch delegateAction {
                case .stopLoading:
                    state.enterCode.startFeedbackPincodeInFlight = false
                    state.enterCode.pinCodeInput.value = ""
                    state.participantEvents.startFeedbackPincodeInFlight = nil
                }
                return .none
                
            case .participantEvents:
                return .none
                
            case .enterCode:
                return .none
                
            case .toolbar(let toolbarButtonAction):
                switch toolbarButtonAction {
                    
                case .joinEventButtonTap:
                    state.destination = .joinEvent(.init())
                case .activityButtonTap:
                    state.destination = .activity(state.session.activity.items)
                    return .run { _ in
                        do {
                            try await apiClient.markActivityAsSeen()
                        } catch {
                            Logger.debug("Reset new feedback failed with error: \(error.localizedDescription)")
                        }
                    }
                }
                return .none
                
            case .moreSection:
                return .none
                
            case .initialiseFeedback:
                return .none
                
            case .signUpButtonTap:
                return .send(.delegate(.navigateToSignUp))
  
            case .delegate:
                return .none
                
            case .managerEvents:
                return .none
                
            case .deleteAccount:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Tabbar.Destination.State: Sendable, Equatable {}
