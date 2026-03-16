import SwiftUI

extension EnvironmentValues {
    @Entry var isLoading: Bool = false
}

public extension View {
    func isLoading(_ isLoading: Bool) -> some View {
        environment(\.isLoading, isLoading)
    }
}
