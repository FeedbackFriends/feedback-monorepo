import SwiftUI
import UIKit

public extension View {
    /// Unlike onAppear, viewDidAppear runs after the navigation animation finishes.
    func onNavigationTransitionCompleted(_ action: @escaping @MainActor () -> Void) -> some View {
        background(NavigationAppearanceObserver(action: action).allowsHitTesting(false))
    }
}

private struct NavigationAppearanceObserver: UIViewControllerRepresentable {
    let action: @MainActor () -> Void

    func makeUIViewController(context: Context) -> ObserverController {
        let controller = ObserverController()
        controller.action = action
        return controller
    }

    func updateUIViewController(_ controller: ObserverController, context: Context) {
        controller.action = action
    }

    final class ObserverController: UIViewController {
        var action: (@MainActor () -> Void)?

        override func loadView() {
            view = UIView()
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = false
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            action?()
        }
    }
}
