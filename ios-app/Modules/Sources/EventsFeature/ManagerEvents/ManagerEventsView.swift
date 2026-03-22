import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI

public struct ManagerEventsView: View {
    
    @Bindable var store: StoreOf<ManagerEvents>
    
    public init(store: StoreOf<ManagerEvents>) {
        self.store = store
    }
    
    public var body: some View {
        let eventDetailStore = $store.scope(state: \.destination?.eventDetail, action: \.destination.eventDetail)
		Group {
			switch store.segmentedControl {
				
			case .yourEvents:
				ScrollView {
					VStack {
						TagFilterView(filter: $store.filterCollection)
						if let managerEvents = store.session.managerData?.managerEvents {
							managerEventsListView(
								todayEvents: managerEvents.filter { $0.date.isToday },
								comingUpEvents: managerEvents.filter { $0.date.isAfterToday },
								previousEvents: managerEvents.filter { $0.date.isBeforeToday }
							)
						}
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

extension ManagerEventsView {
    
    func managerEventsListView(
        todayEvents: [ManagerEvent],
        comingUpEvents: [ManagerEvent],
        previousEvents: [ManagerEvent]
    ) -> some View {
        LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
            if todayEvents.isEmpty && comingUpEvents.isEmpty && previousEvents.isEmpty {
                EmptyStateView(
                    message: "Create a new session by tapping the + button."
                )
            } else {
                if store.filterCollection.allEnabled {
                    if !todayEvents.isEmpty {
                        CustomSection(title: "Today") {
                            ForEach(todayEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                    if !comingUpEvents.isEmpty {
                        CustomSection(title: "Coming up") {
                            ForEach(comingUpEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                        
                    }
                    if !previousEvents.isEmpty {
                        CustomSection(title: "Previous") {
                            ForEach(previousEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                    
                } else {
                    if !todayEvents.isEmpty && store.filterCollection.todayEnabled {
                        CustomSection(title: "Today") {
                            ForEach(todayEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                    if !comingUpEvents.isEmpty && store.filterCollection.comingUpEnabled {
                        CustomSection(title: "Coming up") {
                            ForEach(comingUpEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                        
                    }
                    if !previousEvents.isEmpty && store.filterCollection.previousEnabled {
                        CustomSection(title: "Previous") {
                            ForEach(previousEvents) { event in
                                managerEventListItem(event)
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 80)
        .padding(.horizontal, Theme.padding)
    }
    
    func managerEventListItem(_ event: ManagerEvent) -> some View {
        Button {
            store.send(.managerEventTap(event))
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        if let overallFeedbackSummary = event.overallFeedbackSummary, overallFeedbackSummary.unseenResponses > 0 {
                            Text("\(overallFeedbackSummary.unseenResponses) new")
                                .font(.montserratBold, 10)
                                .padding(4)
                                .padding(.horizontal, 4)
                                .foregroundStyle(Color.themeOnPrimaryAction)
                                .background(Color.themeBlue)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                        }
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.montserratRegular, 10)
                            if let pinCode = event.pinCode?.value {
                                Text("#\(pinCode)")
                                    .font(.montserratSemiBold, 10)
                            }
                        }
                        Spacer()
                        Image.chevronRight
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.themeText.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.montserratRegular, 12)
                .foregroundColor(Color.themeText)
                .padding(.all, 10)
                if let overallFeedbackSummary = event.overallFeedbackSummary {
                    FeedbackPercentageBarView(feedback: overallFeedbackSummary.segmentationStats)
                        .frame(height: 10)
                } else {
                    EmptyFeedbackSegmentationStatsView()
                }
            }
            .background(Color.themeSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .buttonStyle(OpacityButtonStyle())
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

#Preview("Events") {
	NavigationStack {
        ManagerEventsView(
            store: .init(
                initialState: ManagerEvents.State(
                    session: .init(value: .mock())
                ),
                reducer: {
                    ManagerEvents()
                }
            )
        )
        .navigationTitle("Events")
    }
}

#Preview("Empty") {
    NavigationStack {
        ManagerEventsView(
            store: .init(
                initialState: ManagerEvents.State(
                    session: .init(value: .empty())
                ),
                reducer: {
                    ManagerEvents()
                }
            )
        )
        .navigationTitle("Events")
    }
}
