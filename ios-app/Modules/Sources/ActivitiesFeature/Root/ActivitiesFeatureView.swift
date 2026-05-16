import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI

public struct ActivitiesFeatureView: View {
    
    @Bindable var store: StoreOf<ActivitiesFeature>
    
    public init(store: StoreOf<ActivitiesFeature>) {
        self.store = store
    }
    
    public var body: some View {
        let eventDetailStore = $store.scope(state: \.destination?.eventDetail, action: \.destination.eventDetail)
        let managerEvents = store.session.managerData?.activities ?? []
		Group {
			switch store.segmentedControl {
				
			case .yourEvents:
				ScrollView {
					VStack {
						TagFilterView(filter: $store.filterCollection)
                        managerEventsListView(
                            todayEvents: managerEvents.filter { $0.date.isToday },
                            comingUpEvents: managerEvents.filter { $0.date.isAfterToday },
                            previousEvents: managerEvents.filter { $0.date.isBeforeToday }
                        )
					}
				}
				.tag(SegmentedControlMenu.yourEvents)
				
			case .participating:
				ScrollView {
					ParticipantEventsView(
						store: store.scope(
							state: \.participantEvents,
							action: \.participantEvents
						)
					)
				}
				.tag(SegmentedControlMenu.participating)
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
        .lineSpacing(7)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .foregroundStyle(Color.themeText)
        .navigationDestination(
            item: eventDetailStore
        ) { store in
            EventDetailFeatureView(store: store)
                .navigationTitle(store.navigationTitle)
        }
		.overlay(alignment: .bottom) {
			CustomSegmentedPicker(selectedSegmentedControl: $store.segmentedControl.animation())
				.padding(.bottom, 12)
		}
    }
}

extension ActivitiesFeatureView {
    func managerEventsListView(
        todayEvents: [Activity],
        comingUpEvents: [Activity],
        previousEvents: [Activity]
    ) -> some View {
        ManagerSessionsListView(
            todayEvents: store.filterCollection.allEnabled || store.filterCollection.todayEnabled ? todayEvents : [],
            comingUpEvents: store.filterCollection.allEnabled || store.filterCollection.comingUpEnabled ? comingUpEvents : [],
            previousEvents: store.filterCollection.allEnabled || store.filterCollection.previousEnabled ? previousEvents : [],
            onEventTap: { store.send(.managerEventTap($0.event)) }
        )
        .padding(.bottom, 80)
        .padding(.horizontal, Theme.padding)
    }
}

#Preview("Events") {
	NavigationStack {
        ActivitiesFeatureView(
            store: .init(
                initialState: ActivitiesFeature.State(
                    session: .init(value: .mock())
                ),
                reducer: {
                    ActivitiesFeature()
                }
            )
        )
        .navigationTitle("Events")
    }
}

#Preview("Empty") {
    NavigationStack {
        ActivitiesFeatureView(
            store: .init(
                initialState: ActivitiesFeature.State(
                    session: .init(value: .empty())
                ),
                reducer: {
                    ActivitiesFeature()
                }
            )
        )
        .navigationTitle("Events")
    }
}
