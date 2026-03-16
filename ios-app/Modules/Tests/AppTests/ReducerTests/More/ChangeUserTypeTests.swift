@testable import MoreFeature
import Testing
import ComposableArchitecture
import Foundation
import Domain

@MainActor
struct ChangeUserTypeTests {
    
    @Test
    func `Save button updates user type successfully and refreshes session`() async {
        let mockRole = Role.manager
        let store = TestStore(initialState: ChangeUserType.State(selectedUserType: mockRole)) {
            ChangeUserType()
        } withDependencies: {
            $0.apiClient.updateAccountRole = { _ in }
        }
        await store.send(.saveButtonTap) {
            $0.isLoading = true
        }
        await store.receive(\.updateAccountRoleResponse) {
            $0.isLoading = false
        }
        await store.receive(\.delegate, .refreshSession)
    }
    
    @Test
    func `Save button shows error alert when updating user type fails`() async {
        struct Failure: Error, Equatable {}
        
        let store = TestStore(initialState: ChangeUserType.State(selectedUserType: Role.manager)) {
            ChangeUserType()
        } withDependencies: {
            $0.apiClient.updateAccountRole = { _ in throw Failure() }
        }
        
        await store.send(.saveButtonTap) {
            $0.isLoading = true
        }
        
        await store.receive(\.presentError) {
            $0.isLoading = false
            $0.destination = .alert(.init(error: Failure()))
        }
        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
    }
    
    @Test
    func `Close button triggers dismissal correctly`() async {
        let didDismiss = LockIsolated(false)
        
        let store = TestStore(initialState: ChangeUserType.State(selectedUserType: Role.manager)) {
            ChangeUserType()
        } withDependencies: {
            $0.dismiss = .init({
                didDismiss.setValue(true)
            })
        }
        
        #expect(!didDismiss.value)
        await store.send(.closeButtonTap)
        #expect(didDismiss.value)
    }
}
