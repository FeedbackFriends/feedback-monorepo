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
            modifyAccount: { _, _, _ in
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
            getBootstrap: {
                try await Task.sleep(for: .seconds(delay))
                return .mock()
                
            },
            startFeedbackEvent: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock
            },
            submitFeedback: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return true
            },
            createActivity: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            updateActivity: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            deleteActivity: { _ in },
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
            joinEvent: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            markEventAsSeen: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            sendNotification: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            updateRole: { _ in
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            seedParticipantWithData: { .init(token: "mock-seed-participant-with-data") },
            seedParticipantEmpty: { .init(token: "mock-seed-participant-empty") },
            seedManagerWithData: { .init(token: "mock-seed-manager-with-data") },
            seedManagerEmpty: { .init(token: "mock-seed-manager-empty") },
            seedEmptyAccount: { .init(token: "mock-seed-empty-account") },
            resetDatabase: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            },
            login: { id in .init(token: "mock-login-\(id)") },
            getBootstrapUpdate: {
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            markNotificationHistoryAsSeen: {
                try await Task.sleep(for: .seconds(delay))
                return ()
            }
        )
    }
}
