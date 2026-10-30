import SwiftUI

/// A dedicated window host: no app startup, login, network, or backend dependencies.
@main
struct SnapshotHost: App {
    var body: some Scene {
        WindowGroup { Color.clear }
    }
}
