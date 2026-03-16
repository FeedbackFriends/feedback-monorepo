@testable import EventsFeature
import Testing
import ComposableArchitecture
import Foundation

struct DeleteConfirmationTests {
    
    @Test
    func `Delete button removes event successfully and shows success overlay`() async {
        let eventId = UUID()
        let deletedEvent: LockIsolated<UUID?> = .init(nil)
        let store = await TestStore(initialState: DeleteConfirmation.State(eventId: eventId)) {
            DeleteConfirmation()
        } withDependencies: {
            $0.apiClient.deleteEvent = { @MainActor in
                deletedEvent.setValue($0)
            }
        }
        
        await store.send(.deleteButtonTap) {
            $0.deleteEventInFlight = true
        }
        
        await store.receive(\.eventDeletedResponse) {
            $0.deleteEventInFlight = false
            $0.showSuccessOverlay = true
        }
        
        await store.receive(\.delegate, .dismissEventDetail)
        #expect(deletedEvent.value == eventId)
    }
    
    @Test
    func `Delete button shows error alert when deletion fails`() async {
        struct Failure: Error, Equatable {}
        let store = await TestStore(initialState: DeleteConfirmation.State(eventId: UUID())) {
            DeleteConfirmation()
        } withDependencies: {
            $0.apiClient.deleteEvent = { _ in throw Failure() }
        }
        
        await store.send(.deleteButtonTap) {
            $0.deleteEventInFlight = true
        }
        
        await store.receive(\.presentError) {
            $0.deleteEventInFlight = false
            $0.destination = .alert(.init(error: Failure()))
        }
    }
    
    @Test
    func `Cancel button dismisses confirmation dialog`() async {
        let didDismiss = LockIsolated(false)
        let store = await TestStore(initialState: DeleteConfirmation.State(eventId: UUID())) {
            DeleteConfirmation()
        } withDependencies: {
            $0.dismiss = .init({
                didDismiss.setValue(true)
            })
        }
        #expect(!didDismiss.value)
        await store.send(.cancelButtonTap)
        #expect(didDismiss.value)
    }
}
