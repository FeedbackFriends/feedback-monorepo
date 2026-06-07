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

#Preview("With activities") {
    ActivityListView(
        store: .init(
            initialState: .init(bootstrap: .init(value: .mock())),
            reducer: { ActivityList() }
        )
    )
}

#Preview("Empty") {
    ActivityListView(
        store: .init(
            initialState: .init(bootstrap: .init(value: .empty())),
            reducer: { ActivityList() }
        )
    )
}
