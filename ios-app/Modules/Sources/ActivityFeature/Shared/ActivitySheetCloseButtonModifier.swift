import DesignSystem
import SwiftUI

extension EnvironmentValues {
    @Entry var dismissActivitySheet: (() -> Void)?
}

struct ActivitySheetCloseButtonModifier: ViewModifier {
    @Environment(\.dismissActivitySheet) private var dismissActivitySheet

    func body(content: Content) -> some View {
        content.toolbar {
            if let dismissActivitySheet {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView(dismiss: dismissActivitySheet)
                        .accessibilityIdentifier("overview_detail_close_button")
                }
            }
        }
    }
}
