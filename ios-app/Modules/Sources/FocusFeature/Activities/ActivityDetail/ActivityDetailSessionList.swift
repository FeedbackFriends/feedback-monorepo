import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct ActivityDetailSessionList: Sendable {
    @ObservableState
    public struct State: Equatable, Sendable {
        let title: String
        let eventTitle: String
        let sections: [EventListSection]

        public init(title: String, eventTitle: String, sections: [EventListSection]) {
            self.title = title
            self.eventTitle = eventTitle
            self.sections = sections
        }
    }

    public enum Action: Sendable {
        case eventTapped(Event)
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case eventTapped(Event)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .eventTapped(let event):
                return .send(.delegate(.eventTapped(event)))

            case .delegate:
                return .none
            }
        }
    }
}
