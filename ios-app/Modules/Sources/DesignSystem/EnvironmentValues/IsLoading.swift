import SwiftUI

extension EnvironmentValues {
    @Entry var isLoading: Bool = false
    /// Explicit reference time for deterministic rendering; nil follows the live clock.
    @Entry public var referenceDate: Date?
}

public extension View {
    func isLoading(_ isLoading: Bool) -> some View {
        environment(\.isLoading, isLoading)
    }
}
