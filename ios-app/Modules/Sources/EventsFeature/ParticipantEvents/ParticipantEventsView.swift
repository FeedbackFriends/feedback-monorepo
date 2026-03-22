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
        let startFeedbackConfirmationStore = $store.scope(
            state: \.destination?.startFeedbackConfirmation,
            action: \.destination.startFeedbackConfirmation
        )
        ScrollView {
            LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                let participantEvents = store.session.participantEvents
                if participantEvents.isEmpty {
                    EmptyStateView(
                        message: "Sessions you are attending will be visible here."
                    )
                } else {
                    let todayMeetings = participantEvents.filter { $0.date.isToday }
                    let comingUpMeetings = participantEvents.filter { $0.date.isAfterToday }
                    let pastMeetings = participantEvents.filter { $0.date.isBeforeToday }
                    if !todayMeetings.isEmpty {
                        CustomSection(title: "Today") {
                            ForEach(todayMeetings.sorted { $0.date > $1.date }) { event in
                                listItem(event)
                            }
                        }
                    }
                    if !pastMeetings.isEmpty {
                        CustomSection(title: "Past week") {
                            ForEach(pastMeetings) { event in
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
                }
            }
            .padding(.bottom, 80)
            .padding(.horizontal, Theme.padding)
        }
        .foregroundColor(Color.themeText)
        .scrollContentBackground(.hidden)
        .background(Color.themeBackground)
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
        .sheet(item: startFeedbackConfirmationStore) { pinCode in
            pinCode.withState { pinCode in
                StartFeedbackConfirmationView(startFeedback: {
                    store.send(.confirmedToStartFeedback(pinCode: pinCode))
                })
                .presentationDetents([.height(300)])
            }
        }
    }
}

extension ParticipantEventsView {
    
    func listItem(_ event: ParticipantEvent) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(event.title)
                            .font(.montserratSemiBold, 14)
                        Spacer()
                        if event.recentlyJoined {
                            Text("Recently joined")
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
                        Text("Submitted")
                            .font(.montserratSemiBold, 14)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(Color.themeText.gradient.opacity(0.5))
                    } else {
                        if let pinCode = event.pinCode {
                            let startFeedbackPincodeInFlight = store.startFeedbackPincodeInFlight == event.pinCode
                            Button("Start") {
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
