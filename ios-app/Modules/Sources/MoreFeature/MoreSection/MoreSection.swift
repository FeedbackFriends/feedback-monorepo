import Domain
import Foundation
import ComposableArchitecture

@Reducer
public struct MoreSection: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var privacyPolicyUrl: URL?
        var appStoreReviewUrl: URL?
        @Presents var productContact: ProductContact.State?
        public init() {}
    }
    
    public enum Action: BindableAction {
        case onNotificationsButtonTap
        case onFeedbackButtonTap
        case onReportBugButtonTap
        case onSupportUsButtonTap
        case binding(BindingAction<State>)
        case onAppear
        case productContact(PresentationAction<ProductContact.Action>)
    }
    
    public init() {}
    
    @Dependency(\.openURL) var openURL
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.uuid) var uuid
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.privacyPolicyUrl = systemClient.privacyPolicyUrl()
                state.appStoreReviewUrl = systemClient.appStoreReviewUrl()
                return .none
                
            case .onNotificationsButtonTap:
                return .run { [openURL = self.openURL, systemClient = self.systemClient] _ in
                    guard let settingsURL = URL(string: await systemClient.openAppSettings()) else { return }
                    await openURL(settingsURL)
                }
                
            case .onFeedbackButtonTap:
                guard state.productContact == nil else { return .none }
                state.productContact = .init(kind: .productFeedback, submissionID: uuid())
                return .none
                
            case .onReportBugButtonTap:
                guard state.productContact == nil else { return .none }
                state.productContact = .init(kind: .bugReport, submissionID: uuid())
                return .none
                
            case .onSupportUsButtonTap:
                return .run { [openURL = self.openURL] _ in
                    await openURL(systemClient.appStoreReviewUrl())
                }
                
            case .binding:
                return .none
            case .productContact:
                return .none
            }
        }
        .ifLet(\.$productContact, action: \.productContact) { ProductContact() }
    }
}
