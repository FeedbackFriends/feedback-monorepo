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
            startFeedbackSession: { _ in
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
            createSession: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            updateSession: { _, _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            deleteSession: { _ in },
            createAccount: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            sessionChangedListener: { .never },
            joinSession: { _ in
                try await Task.sleep(for: .seconds(delay))
                return .mock()
            },
            markSessionAsSeen: { _ in
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
            mockIdToken: { "" },
            getBoostrapUpdate: {
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
