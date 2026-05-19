@testable import FocusFeature
import ComposableArchitecture
import Domain
import Foundation
import Testing

@MainActor
struct ActivityDetailTests {

    @Test
    func `Session updates keep existing detail when updated session cannot resolve event`() async {
        let session: Shared<Bootstrap> = .init(value: .mock(numberOfManagerEvents: 1))
        let mockEvent = session.wrappedValue.managerData!.managerEvents[0]
        let initialDetail = mockEvent

        let store = TestStore(
            initialState: ActivityDetail.State(
                eventId: mockEvent.id,
                detail: initialDetail,
                session: session
            )
        ) {
            ActivityDetail()
        }

        await store.send(.sessionUpdated(.empty())) {
            $0.detail = initialDetail
        }
    }
}
