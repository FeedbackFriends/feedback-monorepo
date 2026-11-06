@testable import MoreFeature
import ComposableArchitecture
import Domain
import Foundation
import Localization
import Testing

@MainActor
struct ProductContactTests {
    private let id = UUID(uuidString: "00000000-0000-0000-0000-000000000123")!
    private let metadata = SupportClientMetadata(appVersion: "1.2", appBuild: "42", osVersion: "27.2")

    @Test
    func validationRequiresContentAndHonorsEmailAndUTF16Limits() {
        var feedback = ProductContact.State(kind: .productFeedback, submissionID: id)
        #expect(!feedback.isValid)
        feedback.rating = .happy
        #expect(feedback.isValid)
        feedback.rating = nil
        feedback.message = "Comment only"
        #expect(feedback.isValid)
        var bug = ProductContact.State(kind: .bugReport, submissionID: id)
        bug.message = " \n "
        #expect(!bug.isValid)
        bug.message = "Description"
        #expect(bug.isValid)
        bug.contactEmail = "invalid"
        #expect(!bug.isValid)
        bug.contactEmail = " reply@example.com "
        #expect(bug.isValid)
        bug.message = String(repeating: "a", count: 5000)
        #expect(bug.isValid)
        bug.message += "a"
        #expect(!bug.isValid)
        bug.message = String(repeating: "😀", count: 2501)
        #expect(!bug.isValid)
        bug.message = "Description"
        bug.expectedBehavior = String(repeating: "a", count: 5001)
        #expect(!bug.isValid)
    }

    @Test
    func duplicateSubmissionAndEditsAreRejectedWhileSendingAndReceiptRequiresServerSuccess() async {
        let clock = TestClock()
        let calls = LockIsolated(0)
        var state = ProductContact.State(kind: .bugReport, submissionID: id)
        state.message = " Description "
        let input = ProductContactInput(
            id: id, kind: .bugReport, rating: nil, message: "Description",
            expectedBehavior: nil, contactEmail: nil, metadata: metadata
        )
        let receipt = ProductContactReceipt(id: id, receivedAt: Date(timeIntervalSince1970: 0))
        let store = TestStore(initialState: state) { ProductContact() } withDependencies: {
            $0.continuousClock = clock
            $0.systemClient.supportMetadata = { metadata }
            $0.apiClient.submitProductContact = { submitted in
                #expect(submitted == input)
                calls.withValue { $0 += 1 }
                try await clock.sleep(for: .seconds(1))
                return receipt
            }
        }
        await store.send(.sendTapped) { $0.isSending = true }
        await store.receive(\.submissionPrepared) { $0.pendingSubmission = input }
        #expect(store.state.receipt == nil)
        await store.send(.sendTapped)
        await store.send(.inputChanged(.message, "Changed during request"))
        await clock.advance(by: .seconds(1))
        await store.receive(\.submissionResponse) {
            $0.isSending = false
            $0.receipt = receipt
        }
        await store.send(.sendTapped)
        #expect(calls.value == 1)
        #expect(store.state.message == " Description ")
    }

    @Test
    func lostResponsePreservesInputAndRetriesTheSamePayloadAndIdentity() async {
        let inputs = LockIsolated<[ProductContactInput]>([])
        let metadataCalls = LockIsolated(0)
        var state = ProductContact.State(kind: .productFeedback, submissionID: id)
        state.message = "Keep this input"
        let input = ProductContactInput(
            id: id, kind: .productFeedback, rating: nil, message: state.message,
            expectedBehavior: nil, contactEmail: nil, metadata: metadata
        )
        let receipt = ProductContactReceipt(id: id, receivedAt: Date(timeIntervalSince1970: 0))
        let store = TestStore(initialState: state) { ProductContact() } withDependencies: {
            $0.systemClient.supportMetadata = {
                metadataCalls.withValue { $0 += 1 }
                return metadata
            }
            $0.apiClient.submitProductContact = { payload in
                let count = inputs.withValue { values in values.append(payload); return values.count }
                if count == 1 { throw URLError(.networkConnectionLost) }
                return receipt
            }
        }
        await store.send(.sendTapped) { $0.isSending = true }
        await store.receive(\.submissionPrepared) { $0.pendingSubmission = input }
        await store.receive(\.submissionResponse) {
            $0.isSending = false
            $0.error = URLError(.networkConnectionLost).localized
        }
        #expect(store.state.message == "Keep this input")
        await store.send(.sendTapped) { $0.isSending = true; $0.error = nil }
        await store.receive(\.submissionResponse) { $0.isSending = false; $0.receipt = receipt }
        #expect(inputs.value == [input, input])
        #expect(metadataCalls.value == 1)
    }

    @Test
    func invalidInputsNeverSendAndEditingAfterFailureStartsANewIdentity() async {
        let newID = UUID(uuidString: "00000000-0000-0000-0000-000000000456")!
        let store = TestStore(initialState: ProductContact.State(kind: .bugReport, submissionID: id)) {
            ProductContact()
        } withDependencies: {
            $0.uuid = .constant(newID)
        }
        await store.send(.sendTapped)
        await store.send(.inputChanged(.message, "Updated description")) {
            $0.message = "Updated description"
            $0.submissionID = newID
        }
        var failed = ProductContact.State(kind: .bugReport, submissionID: id)
        failed.message = "Original description"
        failed.pendingSubmission = ProductContactInput(
            id: id, kind: .bugReport, rating: nil, message: failed.message,
            expectedBehavior: nil, contactEmail: nil, metadata: metadata
        )
        failed.error = URLError(.networkConnectionLost).localized
        let editing = TestStore(initialState: failed) { ProductContact() } withDependencies: {
            $0.uuid = .constant(newID)
        }
        await editing.send(.inputChanged(.message, "Different content")) {
            $0.message = "Different content"
            $0.submissionID = newID
            $0.pendingSubmission = nil
            $0.error = nil
        }
    }

    @Test
    func cancellationReturnsToEditableInputWithoutAnErrorOrReceipt() async {
        var state = ProductContact.State(kind: .bugReport, submissionID: id)
        state.message = "Description"
        let input = ProductContactInput(
            id: id, kind: .bugReport, rating: nil, message: state.message,
            expectedBehavior: nil, contactEmail: nil, metadata: metadata
        )
        let store = TestStore(initialState: state) { ProductContact() } withDependencies: {
            $0.systemClient.supportMetadata = { metadata }
            $0.apiClient.submitProductContact = { _ in throw CancellationError() }
        }
        await store.send(.sendTapped) { $0.isSending = true }
        await store.receive(\.submissionPrepared) { $0.pendingSubmission = input }
        await store.receive(\.submissionCancelled) { $0.isSending = false }
        #expect(store.state.error == nil)
        #expect(store.state.receipt == nil)
        #expect(store.state.canEdit)
    }

    @Test
    func closingAnUnsubmittedFormOnlyDismisses() async {
        let dismissed = LockIsolated(false)
        let store = TestStore(initialState: ProductContact.State(kind: .bugReport, submissionID: id)) {
            ProductContact()
        } withDependencies: {
            $0.dismiss = .init { dismissed.setValue(true) }
        }
        await store.send(.closeTapped)
        #expect(dismissed.value)
        #expect(store.state.pendingSubmission == nil)
    }

    @Test
    func emailAlternativeStaysInAppAndNeverCreatesADatabaseReceipt() async {
        let store = TestStore(initialState: ProductContact.State(kind: .bugReport, submissionID: id)) {
            ProductContact()
        } withDependencies: {
            $0.systemClient.canComposeMail = { true }
            $0.systemClient.supportEmail = { "support@example.com" }
        }
        await store.send(.mailInsteadTapped) { $0.isCheckingMail = true }
        await store.receive(\.mailAvailabilityReceived) {
            $0.isCheckingMail = false
            $0.mailDraft = ProductContact.MailDraft(
                id: id, recipient: "support@example.com", subject: String(appStrings: .moreBugSubject),
                message: String(appStrings: .productContactMailBody("", ""))
            )
        }
        await store.send(.mailFinished(failed: false)) { $0.mailDraft = nil }
        #expect(store.state.receipt == nil)
    }

    @Test
    func unavailableMailOffersExplicitAddressCopyWithoutExternalNavigation() async {
        let copied = LockIsolated<String?>(nil)
        let address = "support@example.com"
        let store = TestStore(initialState: ProductContact.State(kind: .bugReport, submissionID: id)) {
            ProductContact()
        } withDependencies: {
            $0.systemClient.canComposeMail = { false }
            $0.systemClient.supportEmail = { address }
            $0.systemClient.copyText = { copied.setValue($0) }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)
        await store.send(.mailInsteadTapped)
        await store.receive(\.mailAvailabilityReceived)
        #expect(store.state.alert != nil)
        #expect(copied.value == nil)
        #expect(store.state.mailDraft == nil)
        await store.send(.alert(.presented(.copyEmail(address))))
        #expect(copied.value == address)
        #expect(store.state.receipt == nil)
    }
}
