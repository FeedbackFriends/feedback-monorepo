import Localization
import Domain
import Foundation
import DesignSystem
import ComposableArchitecture
import Logger
import Utility

@Reducer
public struct MoreSection: Sendable {
    
    @ObservableState
    public struct State: Equatable, Sendable {
        var privacyPolicyUrl: URL?
        var appStoreReviewUrl: URL?
        public init() {}
    }
    
    public enum Action: BindableAction {
        case onNotificationsButtonTap
        case onFeedbackButtonTap
        case onReportBugButtonTap
        case onSupportUsButtonTap
        case binding(BindingAction<State>)
        case onAppear
    }
    
    public init() {}
    
    @Dependency(\.openURL) var openURL
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.authClient) var authClient
    
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
                let subject = String(appStrings: .moreFeedbackSubject)
                return .run { [openURL = self.openURL, systemClient = self.systemClient] _ in
                    let deviceSummary = await MainActor.run { DeviceInfo().summary() }
                    let body = String(appStrings: .moreEmailBody(deviceSummary))
                    await openURL(systemClient.openEmail(subject: subject, body: body))
                }
                
            case .onReportBugButtonTap:
                let subject = String(appStrings: .moreBugSubject)
                return .run { [openURL = self.openURL, systemClient = self.systemClient] _ in
                    let deviceSummary = await MainActor.run { DeviceInfo().summary() }
                    let body = String(appStrings: .moreEmailBody(deviceSummary))
                    await openURL(systemClient.openEmail(subject: subject, body: body))
                }
                
            case .onSupportUsButtonTap:
                return .run { [openURL = self.openURL] _ in
                    await openURL(systemClient.appStoreReviewUrl())
                }
                
            case .binding:
                return .none
            }
        }
    }
}
