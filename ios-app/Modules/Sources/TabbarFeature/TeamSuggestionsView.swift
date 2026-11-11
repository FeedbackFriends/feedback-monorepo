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
                    Picker(String(appStrings: .suggestionsTitle), selection: $store.section) {
                        Text(String(appStrings: .improvementsSuggestions)).tag(TeamSuggestions.Section.suggestions)
                        Text(String(appStrings: .improvementsActive)).tag(TeamSuggestions.Section.active)
                        Text(String(appStrings: .improvementsResults)).tag(TeamSuggestions.Section.results)
                    }
                    .pickerStyle(.segmented)
                    if store.section == .suggestions { SuggestionFormView(store: store) }
                    if store.reportSubmitted { Text(String(appStrings: .suggestionsReportSubmitted)).bodyTextStyle() }
                    if store.isBusy { ProgressView().frame(maxWidth: .infinity) }
                    if store.hasLoaded && store.visibleSuggestions.isEmpty {
                        Text(String(appStrings: .suggestionsEmpty)).bodyTextStyle()
                    }
                    ForEach(store.visibleSuggestions) { suggestion in
                        SuggestionRowView(
                            suggestion: suggestion,
                            isBusy: store.isBusy,
                            support: { store.send(.support(suggestion.id)) },
                            withdraw: { store.send(.withdrawTapped(suggestion.id)) },
                            report: { store.send(.reportTapped(suggestion.id)) },
                            answer: { store.send(.answer(suggestion.id, $0, $1)) }
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
    let answer: (String, EvaluationAnswer) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padding) {
            Text(suggestion.problem).rowTitleTextStyle()
            Text(suggestion.impact).bodyTextStyle()
            if let solution = suggestion.solution { Text(solution).bodyTextStyle() }
            if suggestion.hasFiveSupporters {
                Text(String(appStrings: .suggestionsFiveSupporters)).supportingTextStyle()
            }
            ForEach(suggestion.outcomes) { outcome in
                VStack(alignment: .leading, spacing: Theme.padding) {
                    Text(String(appStrings: outcome.outcome == .continued ? .outcomeContinue : outcome.outcome == .adjust ? .outcomeAdjust : .outcomeStop)).rowTitleTextStyle()
                    if let plan = suggestion.trials.first(where: { $0.id == outcome.trialID }) { Text(plan.change).bodyTextStyle() }
                    Text(outcome.explanation).bodyTextStyle()
                }
            }
            ForEach(suggestion.evaluations) { evaluation in
                SuggestionEvaluationView(evaluation: evaluation,
                                         change: suggestion.trials.first(where: { $0.id == evaluation.trialID })?.change,
                                         answer: { answer(evaluation.id, $0) })
            }
            if let trial = suggestion.trials.first {
                SuggestionTrialView(trial: trial, isCurrent: !suggestion.outcomes.contains { $0.trialID == trial.id })
                if suggestion.trials.count > 1 {
                    DisclosureGroup(String(appStrings: .suggestionsTrialHistory)) {
                        ForEach(suggestion.trials.dropFirst()) { previous in
                            SuggestionTrialView(trial: previous, isCurrent: false)
                        }
                    }
                }
            }
            if let latest = suggestion.decisions.first {
                SuggestionDecisionView(decision: latest)
                if suggestion.decisions.count > 1 {
                    DisclosureGroup(String(appStrings: .suggestionsDecisionHistory)) {
                        ForEach(suggestion.decisions.dropFirst()) { decision in
                            SuggestionDecisionView(decision: decision)
                        }
                    }
                }
            } else {
                Text(String(appStrings: .suggestionsReceived)).supportingTextStyle()
            }
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

private struct SuggestionDecisionView: View {
    let decision: SuggestionDecision

    private var status: String {
        switch decision.status {
        case .reviewing: String(appStrings: .suggestionsStatusReviewing)
        case .planned: String(appStrings: .suggestionsStatusPlanned)
        case .deferred: String(appStrings: .suggestionsStatusDeferred)
        case .declined: String(appStrings: .suggestionsStatusDeclined)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padding) {
            Text(status).rowTitleTextStyle()
            Text(decision.explanation).bodyTextStyle()
            Text(String(appStrings: .suggestionsResponsible(decision.responsibleName))).supportingTextStyle()
            if let date = decision.followUpDate {
                Text(String(appStrings: .suggestionsFollowUp(L10n.Format.date(date, timeZone: .gmt)))).supportingTextStyle()
            }
            Text(String(appStrings: .suggestionsPublished(L10n.Format.date(decision.publishedAt, time: .shortened)))).supportingTextStyle()
        }
    }
}

private struct SuggestionTrialView: View {
    let trial: SuggestionTrial
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padding) {
            Text(String(appStrings: isCurrent ? .suggestionsTrialTitle : .suggestionsTrialHistory)).rowTitleTextStyle()
            Text(trial.change).bodyTextStyle()
            Text(String(appStrings: .suggestionsTrialBenefit(trial.intendedBenefit))).bodyTextStyle()
            Text(String(appStrings: .suggestionsResponsible(trial.responsibleName))).supportingTextStyle()
            if isCurrent && trial.needsReassignment {
                Text(String(appStrings: .suggestionsTrialReassignment)).supportingTextStyle()
            }
            Text(String(appStrings: .suggestionsTrialPeriod(
                L10n.Format.date(trial.startDate, timeZone: .gmt),
                L10n.Format.date(trial.endDate, timeZone: .gmt)
            ))).supportingTextStyle()
            Text(String(appStrings: .suggestionsFollowUp(L10n.Format.date(trial.followUpDate, timeZone: .gmt)))).supportingTextStyle()
        }
    }
}

private struct SuggestionEvaluationView: View {
    let evaluation: SuggestionEvaluation
    let change: String?
    let answer: (EvaluationAnswer) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.padding) {
            Text(String(appStrings: .evaluationQuestion)).rowTitleTextStyle()
            if let change { Text(change).bodyTextStyle() }
            Text(String(appStrings: .evaluationDeadline(L10n.Format.date(evaluation.closesAt, time: .shortened)))).supportingTextStyle()
            if let summary = evaluation.summary {
                Text(summaryText(summary)).bodyTextStyle()
            } else if evaluation.closed {
                Text(String(appStrings: .evaluationClosed)).bodyTextStyle()
            } else if evaluation.eligible {
                Text(String(appStrings: .evaluationPrivacy)).supportingTextStyle()
                ForEach(EvaluationAnswer.allCases) { value in
                    Button(label(value)) { answer(value) }
                        .buttonStyle(LargeButtonStyle())
                        .accessibilityAddTraits(evaluation.myAnswer == value ? .isSelected : [])
                }
                if evaluation.myAnswer != nil { Text(String(appStrings: .evaluationSaved)).supportingTextStyle() }
            }
        }
    }

    private func label(_ answer: EvaluationAnswer) -> String {
        switch answer {
        case .better: String(appStrings: .evaluationBetter)
        case .unchanged: String(appStrings: .evaluationUnchanged)
        case .worse: String(appStrings: .evaluationWorse)
        case .cannotAssess: String(appStrings: .evaluationCannotAssess)
        }
    }

    private func summaryText(_ summary: SuggestionEvaluation.Summary) -> String {
        switch summary {
        case .improved: String(appStrings: .evaluationImproved)
        case .mixed: String(appStrings: .evaluationMixed)
        case .notImproved: String(appStrings: .evaluationNotImproved)
        case .insufficientResponses: String(appStrings: .evaluationInsufficientResponses)
        }
    }
}
