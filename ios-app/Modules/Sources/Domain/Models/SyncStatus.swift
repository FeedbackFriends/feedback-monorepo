import Foundation

public struct SyncStatus: Equatable, Sendable {
    public enum VisibleSyncState: Equatable, Sendable {
        case hidden
        case syncing
        case synced
    }

    public var isSyncing: Bool
    public var lastUpdatedAt: Date?
    public var visibleSyncState: VisibleSyncState

    public init(
        isSyncing: Bool = false,
        lastUpdatedAt: Date? = nil,
        visibleSyncState: VisibleSyncState = .hidden
    ) {
        self.isSyncing = isSyncing
        self.lastUpdatedAt = lastUpdatedAt
        self.visibleSyncState = visibleSyncState
    }
}
