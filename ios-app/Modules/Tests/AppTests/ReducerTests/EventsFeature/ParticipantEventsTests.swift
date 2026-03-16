@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ParticipantEventsTests {

    @Test
    func feedbackSegmentSwitching() async {
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }

        #expect(store.state.selectedSegment == .invited)

        await store.send(.binding(.set(\.selectedSegment, .history))) {
            $0.selectedSegment = .history
        }

        await store.send(.binding(.set(\.selectedSegment, .invited))) {
            $0.selectedSegment = .invited
        }
    }

    @Test
    func historyBadgeAppearsForNewHistoryItemsAndClearsWhenOpeningHistory() async {
        let oldHistoryEvent = participantEvent(id: UUID(0), daysOffset: -1, feedbackSubmitted: true)
        let newHistoryEvent = participantEvent(id: UUID(1), daysOffset: -2, feedbackSubmitted: true)

        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mockParticipant()))) {
            ParticipantEvents()
        }

        await store.send(.participantEventsChanged([oldHistoryEvent])) {
            $0.historyBadgeCount = 0
            $0.hasInitializedHistoryTracking = true
            $0.seenHistoryEventIDs = [oldHistoryEvent.id]
        }

        await store.send(.participantEventsChanged([oldHistoryEvent, newHistoryEvent])) {
            $0.historyBadgeCount = 1
        }

        await store.send(.binding(.set(\.selectedSegment, .history))) {
            $0.selectedSegment = .history
            $0.historyBadgeCount = 0
            $0.seenHistoryEventIDs = [oldHistoryEvent.id, newHistoryEvent.id]
        }
    }
    
    @Test
    func infoButtonTap() async {
        let mockEvent = ParticipantEvent.mock()
        
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }
        
        await store.send(.infoButtonTap(mockEvent)) {
            $0.destination = .info(mockEvent)
        }
        await store.send(.binding(.set(\.destination, nil))) {
            $0.destination = nil
        }
    }
    
    @Test
    func `Start feedback button triggers delegate with correct pin code`() async {
        let pinCode = PinCode(value: "1234")
        
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }
        
        await store.send(.startFeedbackButtonTap(pinCode: pinCode)) {
            $0.startFeedbackPincodeInFlight = pinCode
        }
        
        await store.receive(\.delegate, .startFeedback(pinCode: pinCode))
    }
    
    @Test
    func confirmedToStartFeedback() async {
        let pinCode = PinCode(value: "1234")
        
        let store = TestStore(initialState: ParticipantEvents.State(session: .init(value: .mock()))) {
            ParticipantEvents()
        }
        
        await store.send(.confirmedToStartFeedback(pinCode: pinCode))
        await store.receive(\.startFeedbackButtonTap) {
            $0.startFeedbackPincodeInFlight = pinCode
        }
        await store.receive(\.delegate, .startFeedback(pinCode: pinCode))
    }

    private func participantEvent(id: UUID, daysOffset: Int, feedbackSubmitted: Bool) -> ParticipantEvent {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: daysOffset, to: calendar.startOfDay(for: Date()))!

        return ParticipantEvent(
            id: id,
            title: "Event \(id.uuidString.prefix(4))",
            agenda: nil,
            date: date,
            pinCode: PinCode(value: "1234"),
            location: nil,
            durationInMinutes: 60,
            questions: [],
            feedbackSubmitted: feedbackSubmitted,
            ownerInfo: .mock(),
            recentlyJoined: false
        )
    }
}

private extension UUID {
    init(_ value: UInt8) {
        self = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, value))
    }
}
