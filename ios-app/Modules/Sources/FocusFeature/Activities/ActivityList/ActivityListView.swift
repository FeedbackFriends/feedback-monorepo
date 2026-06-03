import Domain
import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ActivityListView: View {
    
    @State private var isActivityIntroPresented = false
    @Bindable var store: StoreOf<ActivityList>

    public init(
        store: StoreOf<ActivityList>
    ) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if store.activities.isEmpty {
                        introCard
                    } else {
                        ForEach(store.activities) { activity in
                            ActivityRowButton(activity: activity) {
                                store.send(.activityTap(activity))
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 88)
            }
            .background(LetsGrowLandingGradient().ignoresSafeArea())
            .navigationTitle("✨ Aktiviteter")
            .toolbar {
                if !store.activities.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isActivityIntroPresented = true
                        } label: {
                            Image.questionmarkCircle
                        }
                        .buttonStyle(ScalingButtonStyle())
                        .accessibilityIdentifier("my_activity_info_button")
                        .accessibilityLabel("Hvad er en aktivitet?")
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    self.store.send(.createActivityButtonTap)
                } label: {
                    Image(systemName: "plus")
                        .titleTextStyle()
                        .foregroundStyle(Color.themeOnPrimaryAction)
                        .frame(width: 56, height: 56)
                        .background(Color.themePrimaryAction.gradient, in: Circle())
                        .glassEffect(in: .circle)
                        .lightShadow()
                }
                .buttonStyle(ScalingButtonStyle())
                .accessibilityIdentifier("my_activity_add_button")
                .accessibilityLabel("Tilføj aktivitet")
                .padding(.trailing, Theme.padding)
                .padding(.bottom, Theme.padding)
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.destination?.activityDetail,
                    action: \.destination.activityDetail
                )
            ) { store in
                ActivityDetailView(store: store)
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.manageActivity,
                    action: \.destination.manageActivity
                )
            ) { store in
                NavigationStack {
                    ManageActivityView(store: store)
                }
            }
            .sheet(isPresented: $isActivityIntroPresented) {
                ActivityIntroSheetView()
                    .presentationDetents([.medium])
            }
        }
    }

    private var introCard: some View {
        ActivityIntroContentView()
            .accessibilityIdentifier("my_activity_intro_text")
    }
}

private struct ActivityIntroSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                introBody
                .padding()
            }
            .navigationTitle("Hvad er en aktivitet?")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
        }
    }

    private var introBody: some View {
        ActivityIntroContentView()
            .accessibilityIdentifier("my_activity_intro_text")
    }
}

private struct ActivityIntroContentView: View {
    private let examples: [(emoji: String, text: String)] = [
        ("🎤", "Et foredrag om ledelse"),
        ("🤖", "En AI-workshop"),
        ("🎾", "En padeltræning"),
        ("📅", "Det månedlige teammøde")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("En 'Aktivitet' er et format, du gentager. Noget, du løbende ønsker at forbedre gennem feedback og erfaringer.\n\nDet kunne være:")
                .bodyTextStyle()
                .foregroundStyle(Color.themeText)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(examples, id: \.text) { example in
                    HStack(alignment: .top, spacing: 10) {
                        Text(example.emoji)
                        Text(example.text)
                            .bodyTextStyle()
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
            }
            Text("\nTryk på plus-knappen for at oprette din første aktivitet.")
                .bodyTextStyle()
                .foregroundStyle(Color.themeText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

private struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(activity.title)
                    .rowTitleTextStyle()
                Spacer()
            }

            Text(activity.events.count == 1 ? "1 mødegang" : "\(activity.events.count) mødegange")
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.themeBackground, in: Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

private struct ActivityRowButton: View {
    let activity: Activity
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ActivityCardView(activity: activity)
        }
        .buttonStyle(.plain)
    }
}

private extension ActivityTrend.Direction {
    var title: String {
        switch self {
        case .improving:
            return "Bliver bedre"
        case .stable:
            return "Stabilt"
        case .declining:
            return "Falder"
        case .insufficientData:
            return "For lidt data"
        }
    }

    var symbolName: String {
        switch self {
        case .improving:
            return "arrow.up.right"
        case .stable:
            return "arrow.right"
        case .declining:
            return "arrow.down.right"
        case .insufficientData:
            return "questionmark"
        }
    }

    var color: Color {
        switch self {
        case .improving:
            return Color.themeSuccess
        case .stable:
            return Color.themeNeutral
        case .declining:
            return Color.themeVerySad
        case .insufficientData:
            return Color.themeNeutral
        }
    }
}

// #Preview {
//     ActivityListView(
//         session: .mock(),
//         store: .init(
//             initialState: .init(bootstrap: .init(value: .mock()), activities: []),
//             reducer: { ActivityList() }
//         )
//     )
// }
