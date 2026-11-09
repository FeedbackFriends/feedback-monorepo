import ComposableArchitecture
import DesignSystem
import Localization
import SwiftUI

public struct EmployeeTeamMembershipView: View {
    @Bindable var store: StoreOf<EmployeeTeamMembership>
    @FocusState private var codeFocused: Bool
    @FocusState private var nameFocused: Bool

    public init(store: StoreOf<EmployeeTeamMembership>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.padding) {
                if store.isBusy {
                    ProgressView().frame(maxWidth: .infinity)
                }
                if let team = store.context?.membership {
                    Text(team.name).largeTitleTextStyle()
                    Text(team.organizationName).supportingTextStyle()
                    Text(String(appStrings: .teamJoinedMessage)).bodyTextStyle()
                    NavigationLink {
                        TeamSuggestionsView(store: store.scope(state: \.suggestions, action: \.suggestions))
                    } label: {
                        Text(String(appStrings: .suggestionsTitle))
                    }
                    .buttonStyle(LargeButtonStyle())
                    .accessibilityIdentifier("team_suggestions")
                    Button(String(appStrings: .teamLeaveAction)) { store.send(.leaveTapped) }
                        .buttonStyle(LargeButtonStyle())
                        .disabled(store.isBusy)
                } else if let request = store.context?.request, request.status == .pending {
                    Text(request.team.name).largeTitleTextStyle()
                    Text(String(appStrings: .teamPendingTitle)).titleTextStyle()
                    Text(String(appStrings: .teamPendingMessage)).bodyTextStyle()
                    Button(String(appStrings: .teamCancelAction)) { store.send(.cancelTapped) }
                        .buttonStyle(LargeButtonStyle())
                        .disabled(store.isBusy)
                } else if store.context?.isLeader == true {
                    Text(String(appStrings: .teamLeaderMessage)).bodyTextStyle()
                } else if store.hasLoaded {
                    if store.context?.request?.status == .rejected {
                        Text(String(appStrings: .teamRejectedMessage)).bodyTextStyle()
                    }
                    Text(String(appStrings: .teamJoinMessage)).bodyTextStyle()
                    TextInputView(
                        title: String(appStrings: .teamCode), prompt: String(appStrings: .teamCode),
                        text: $store.code, isFocused: $codeFocused, capitalization: .never, accessibilityIdentifier: "team_code"
                    )
                    .autocorrectionDisabled()
                    TextInputView(
                        title: String(appStrings: .teamName), prompt: String(appStrings: .teamName),
                        text: $store.name, isFocused: $nameFocused, accessibilityIdentifier: "team_name"
                    )
                    Text(String(appStrings: .teamNameExplanation)).supportingTextStyle()
                    Button(String(appStrings: .teamJoinAction)) {
                        codeFocused = false
                        nameFocused = false
                        store.send(.submit)
                    }
                    .buttonStyle(LargeButtonStyle())
                    .disabled(!store.canSubmit)
                    .accessibilityIdentifier("team_join")
                }
                Button(String(appStrings: .teamRefresh)) { store.send(.refresh) }
                    .buttonStyle(LargeButtonStyle())
                    .disabled(store.isBusy)
                    .accessibilityIdentifier("team_refresh")
            }
            .padding(Theme.padding)
            .frame(maxWidth: Constants.maxWidthForLargeDevices)
            .frame(maxWidth: .infinity)
        }
        .background(LetsGrowLandingGradient())
        .navigationTitle(String(appStrings: .teamTitle))
        .alert($store.scope(state: \.alert, action: \.alert))
        .task { await store.send(.refresh).finish() }
    }
}
