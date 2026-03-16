import ComposableArchitecture
import SwiftUI
import Domain
import DesignSystem

public struct ParticipantEventsView: View {
    @Bindable var store: StoreOf<ParticipantEvents>
    public init(store: StoreOf<ParticipantEvents>) {
        self.store = store
    }
    public var body: some View {
        let infoStore = $store.scope(state: \.destination?.info, action: \.destination.info)
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                segmentPicker
                let participantEvents = filteredParticipantEvents
                if participantEvents.isEmpty {
                    EmptyStateView(
                        title: emptyStateTitle,
                        message: emptyStateMessage
                    )
                } else {
                    switch store.selectedSegment {
                    case .invited:
                        let todayMeetings = participantEvents.filter { $0.date.isToday }.sorted { $0.date > $1.date }
                        let comingUpMeetings = participantEvents.filter { $0.date.isAfterToday }.sorted { $0.date < $1.date }

                        if !todayMeetings.isEmpty {
                            CustomSection(title: "Today") {
                                ForEach(todayMeetings) { event in
                                    listItem(event)
                                }
                            }
                        }

                        if !comingUpMeetings.isEmpty {
                            CustomSection(title: "Coming up") {
                                ForEach(comingUpMeetings) { event in
                                    listItem(event)
                                }
                            }
                        }

                    case .history:
                        let submittedFeedback = participantEvents.filter { $0.feedbackSubmitted }.sorted { $0.date > $1.date }
                        let pastMeetings = participantEvents.filter { !$0.feedbackSubmitted && $0.date.isBeforeToday }.sorted { $0.date > $1.date }

                        if !submittedFeedback.isEmpty {
                            CustomSection(title: "Submitted") {
                                ForEach(submittedFeedback) { event in
                                    listItem(event)
                                }
                            }
                        }

                        if !pastMeetings.isEmpty {
                            CustomSection(title: "Past") {
                                ForEach(pastMeetings) { event in
                                    listItem(event)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 80)
            .padding(.horizontal, Theme.padding)
        }
        .foregroundColor(Color.themeText)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
        .onAppear {
            store.send(.participantEventsChanged(store.session.participantEvents.map { $0 }))
        }
        .onChange(of: store.session.participantEvents) { _, newValue in
            store.send(.participantEventsChanged(newValue.map { $0 }))
        }
        .sheet(item: infoStore) { event in
            event.withState { event in
                EventInfoView(
                    eventTitle: event.title,
                    eventAgenda: event.agenda,
                    ownerName: event.ownerInfo.name,
                    ownerEmail: event.ownerInfo.email,
                    ownerphoneNumber: event.ownerInfo.phoneNumber,
                    date: event.date
                )
                .presentationDetents([.medium])
            }
        }
    }
}

extension ParticipantEventsView {
    var segmentPicker: some View {
        Picker("Participant events filter", selection: $store.selectedSegment) {
            Text("Invitations")
                .tag(ParticipantEvents.Segment.invited)
            Text("History")
                .tag(ParticipantEvents.Segment.history)
        }
        .pickerStyle(.segmented)
        .overlay(alignment: .topTrailing) {
            if store.historyBadgeCount > 0 {
                historyBadge
                    .offset(x: -16, y: -6)
            }
        }
    }

    var filteredParticipantEvents: [ParticipantEvent] {
        let allParticipantEvents = store.session.participantEvents.map { $0 }
        switch store.selectedSegment {
        case .invited:
            return allParticipantEvents.filter { !$0.feedbackSubmitted && ($0.date.isToday || $0.date.isAfterToday) }
        case .history:
            return allParticipantEvents.filter { $0.feedbackSubmitted || $0.date.isBeforeToday }
        }
    }

    var emptyStateTitle: String {
        switch store.selectedSegment {
        case .invited:
            return "No invitations"
        case .history:
            return "No feedback history"
        }
    }

    var emptyStateMessage: String {
        switch store.selectedSegment {
        case .invited:
            return "You'll see upcoming sessions here when you're invited."
        case .history:
            return "Your submitted and past sessions will appear here."
        }
    }

    var historyBadgeText: String {
        if store.historyBadgeCount > 99 {
            return "99+"
        }
        return "\(store.historyBadgeCount)"
    }

    var historyBadge: some View {
        Text(historyBadgeText)
            .font(.montserratBold, 9)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color(.systemRed))
            .clipShape(Capsule())
    }
    
    func listItem(_ event: ParticipantEvent) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        if event.recentlyJoined {
                            Text("New feedback")
                                .font(.montserratBold, 10)
                                .padding(4)
                                .padding(.horizontal, 4)
                                .foregroundStyle(Color.themeOnPrimaryAction)
                                .background(Color.blue.opacity(0.5).gradient)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.montserratRegular, 12)
                .foregroundColor(Color.themeText)
                Divider()
                HStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(event.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.montserratRegular, 10)
                            if let pinCode = event.pinCode {
                                Text("#\(pinCode.value)")
                                    .font(.montserratSemiBold, 10)
                            } else {
                                Text("Udløbet")
                                    .font(.montserratSemiBold, 10)
                            }
                        }
                        Spacer()
                    }
                    .foregroundStyle(Color.themeText)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    Divider()
                    if event.feedbackSubmitted {
                        Text("Sent")
                            .font(.montserratSemiBold, 14)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(Color.themeText.gradient.opacity(0.5))
                    } else {
                        if let pinCode = event.pinCode {
                            let startFeedbackPincodeInFlight = store.startFeedbackPincodeInFlight == event.pinCode
                            Button("Give feedback") {
                                store.send(.startFeedbackButtonTap(pinCode: pinCode))
                            }
                            .disabled(startFeedbackPincodeInFlight)
                            .buttonStyle(PrimaryTextButtonStyle())
                            .isLoading(startFeedbackPincodeInFlight)
                            .frame(maxWidth: .infinity, minHeight: 40)
                        } else {
                            Text("Udløbet")
                                .font(.montserratSemiBold, 14)
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.montserratBold, 14)
            .foregroundStyle(Color.themeText)
            .padding(.all, 10)
        }
        .background(Color.themeSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            store.send(.infoButtonTap(event))
        }
    }
}

#Preview {
    NavigationStack {
        ParticipantEventsView(
            store: StoreOf<ParticipantEvents>.init(
                initialState: ParticipantEvents.State(
                    session: .init(value: .mock())
                ),
                reducer: {
                    ParticipantEvents()
                }
            )
        )
    }
}
