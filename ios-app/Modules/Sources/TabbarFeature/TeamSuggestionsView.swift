import ComposableArchitecture
import DesignSystem
import Domain
import Localization
import SwiftUI

public struct TeamSuggestionsView: View {
    @Bindable var store: StoreOf<TeamSuggestions>
    @Environment(\.scenePhase) private var scenePhase

    public init(store: StoreOf<TeamSuggestions>) { self.store = store }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Theme.padding) {
                Text(String(appStrings: .suggestionsPrivacy)).supportingTextStyle()
                if store.teamID != nil {
                    SuggestionFormView(store: store)
                    if store.reportSubmitted { Text(String(appStrings: .suggestionsReportSubmitted)).bodyTextStyle() }
                    if store.isBusy { ProgressView().frame(maxWidth: .infinity) }
                    if store.hasLoaded && store.suggestions.isEmpty {
                        Text(String(appStrings: .suggestionsEmpty)).bodyTextStyle()
                    }
                    ForEach(store.suggestions) { suggestion in
                        SuggestionRowView(
                            suggestion: suggestion,
                            isBusy: store.isBusy,
                            support: { store.send(.support(suggestion.id)) },
                            withdraw: { store.send(.withdrawTapped(suggestion.id)) },
                            report: { store.send(.reportTapped(suggestion.id)) }
                        )
                    }
                    Button(String(appStrings: .teamRefresh)) { store.send(.refresh) }
                        .buttonStyle(LargeButtonStyle())
                        .disabled(store.isBusy)
                } else {
                    Text(String(appStrings: .suggestionsMembershipRequired)).bodyTextStyle()
                }
            }
            .padding(Theme.padding)
            .frame(maxWidth: Constants.maxWidthForLargeDevices)
            .frame(maxWidth: .infinity)
        }
        .background(LetsGrowLandingGradient())
        .navigationTitle(String(appStrings: .suggestionsTitle))
        .alert($store.scope(state: \.alert, action: \.alert))
        .task { await store.send(.refresh).finish() }
        .refreshable { await store.send(.refresh).finish() }
        .onChange(of: store.teamID) { _, _ in
            store.send(.membershipChanged)
            store.send(.refresh)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.send(.refresh) }
        }
    }
}

private struct SuggestionFormView: View {
    @Bindable var store: StoreOf<TeamSuggestions>
    @FocusState private var problemFocused: Bool
    @FocusState private var impactFocused: Bool
    @FocusState private var solutionFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padding) {
            Text(String(appStrings: .suggestionsNew)).titleTextStyle()
            TextInputView(
                title: String(appStrings: .suggestionsProblem), prompt: String(appStrings: .suggestionsProblem),
                text: $store.problem, isFocused: $problemFocused, axis: .vertical, lineLimit: 2...5,
                accessibilityIdentifier: "suggestion_problem"
            )
            TextInputView(
                title: String(appStrings: .suggestionsImpact), prompt: String(appStrings: .suggestionsImpact),
                text: $store.impact, isFocused: $impactFocused, axis: .vertical, lineLimit: 2...5,
                accessibilityIdentifier: "suggestion_impact"
            )
            TextInputView(
                title: String(appStrings: .suggestionsSolution), prompt: String(appStrings: .suggestionsSolution),
                text: $store.solution, isFocused: $solutionFocused, axis: .vertical, lineLimit: 2...5,
                accessibilityIdentifier: "suggestion_solution"
            )
            Text(String(appStrings: .suggestionsLengthHint)).supportingTextStyle()
            Button(String(appStrings: .suggestionsSubmit)) {
                problemFocused = false
                impactFocused = false
                solutionFocused = false
                store.send(.submit)
            }
            .buttonStyle(LargeButtonStyle())
            .disabled(!store.canSubmit)
            .accessibilityIdentifier("suggestion_submit")
            if store.submitted { Text(String(appStrings: .suggestionsSubmitted)).bodyTextStyle() }
        }
        .disabled(store.isBusy)
    }
}

private struct SuggestionRowView: View {
    let suggestion: Suggestion
    let isBusy: Bool
    let support: () -> Void
    let withdraw: () -> Void
    let report: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padding) {
            Text(suggestion.problem).rowTitleTextStyle()
            Text(suggestion.impact).bodyTextStyle()
            if let solution = suggestion.solution { Text(solution).bodyTextStyle() }
            Text(String(appStrings: .suggestionsSupportCount(suggestion.supportCount))).supportingTextStyle()
            Button(String(appStrings: suggestion.supportedByMe ? .suggestionsRemoveSupport : .suggestionsSupport), action: support)
                .buttonStyle(LargeButtonStyle())
            Button(String(appStrings: .suggestionsReport), action: report)
                .buttonStyle(LargeButtonStyle())
            if suggestion.mine {
                Button(String(appStrings: .suggestionsWithdraw), action: withdraw)
                    .buttonStyle(LargeButtonStyle())
            }
        }
        .surfaceCard()
        .disabled(isBusy)
    }
}
