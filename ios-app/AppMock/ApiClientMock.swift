import RootFeature
import SwiftUI
import Domain
import Foundation
import ComposableArchitecture
import DesignSystem
import Logger
import Utility

extension APIClient {
    static var mock: Self {
        let delay = 1
        return .init(
            deleteAccount: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            updateAccount: { _, _, _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            linkFCMTokenToAccount: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            logout: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            getSession: {
                try await Task.sleep(for: .seconds(delay))
                return .mock()
                
            },
            startFeedbackSession: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock
            },
            submitFeedback: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return true
            },
            createEvent: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            updateEvent: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            deleteEvent: { _ in },
            createAccount: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            sessionChangedListener: { .never },
            joinEvent: { _ in },
            markEventAsSeen: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            updateAccountRole: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            getMockToken: { "" },
            getUpdatedSession: {
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            markActivityAsSeen: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            }
        )
    }
}
