import DesignSystem
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest
@testable import ActivityFeature
@testable import EnterCodeFeature
@testable import MoreFeature
@testable import FeedbackFlowFeature
@testable import RootFeature
@testable import SignUpFeature
@testable import TabbarFeature

/// Capture every catalog state, including native alerts, through the same pipeline.
/// This writes diagnostic images only. It never records approved reference screenshots.
nonisolated final class ScreenSnapshotTests: XCTestCase {
    @MainActor
    private var samples: [ScreenSnapshotSample] {
        let catalogs: [[ScreenSnapshotSample]] = [
            ActivityFeatureScreenSnapshotCatalog.samples,
            EnterCodeFeatureScreenSnapshotCatalog.samples,
            FeedbackFlowFeatureScreenSnapshotCatalog.samples,
            MoreFeatureScreenSnapshotCatalog.samples,
            RootFeatureScreenSnapshotCatalog.samples,
            SignUpFeatureScreenSnapshotCatalog.samples,
            TabbarFeatureScreenSnapshotCatalog.samples
        ]
        return catalogs.flatMap { $0 }
    }

    @MainActor
    func testCaptureCatalog() async throws {
        executionTimeAllowance = 300
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("screenshots", isDirectory: true)
        let output = root.appendingPathComponent("capture", isDirectory: true)
        if FileManager.default.fileExists(atPath: output.path) {
            try FileManager.default.removeItem(at: output)
        }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let strategy = Snapshotting<UIImage, UIImage>.image
        for sample in samples {
            let image = try await render(sample.makeView(), identifier: sample.id, size: sample.size)
            try autoreleasepool {
                let data = strategy.diffing.toData(image)
                XCTAssertFalse(data.isEmpty, "Empty capture: \(sample.id)")
                try data.write(to: output.appendingPathComponent("\(sample.id).png"), options: .atomic)
            }
        }
        let manifest: [String: Any] = [
            "renderer": "Point-Free SnapshotTesting", "ids": samples.map(\.id), "failures": [], "reviewMode": "visual",
            "systemVersion": UIDevice.current.systemVersion,
            "simulatorModel": ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "unknown",
            "scale": 3, "locale": "da_DK", "appearance": "light", "dynamicType": "large"
        ]
        try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
            .write(to: output.appendingPathComponent("manifest.json"), options: .atomic)

    }

    @MainActor
    private func render(_ view: AnyView, identifier: String, size: CGSize = .init(width: 402, height: 874)) async throws -> UIImage {
        let verifiesRefreshAlert = identifier == "activities.refresh-error"
        let verifiesAlert = identifier == "sign-in.error" || verifiesRefreshAlert
        let sheetIdentifiers: Set<String> = [
            "activity.delete-confirmation", "session.delete-confirmation", "activity.how-it-works",
            "session.invite", "questions.answer-type-help",
            "feedback.rating-prompt", "feedback.event-info", "notifications.permission",
            "join-session.ready", "join-session.success"
        ]
        let requiresSheet = sheetIdentifiers.contains(identifier)
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(animationsWereEnabled) }
        let controller = UIHostingController(rootView: view)
        controller.safeAreaRegions = .container
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let previousWindow = scene.windows.first(where: \.isKeyWindow)
        let window = SnapshotWindow(windowScene: scene)
        window.frame = CGRect(origin: .zero, size: size)
        window.isOpaque = true
        window.backgroundColor = UIColor(Color.themeBackground)
        window.overrideUserInterfaceStyle = .light
        window.traitOverrides.preferredContentSizeCategory = .large
        window.traitOverrides.displayScale = 3
        window.traitOverrides.displayGamut = .SRGB
        window.contentScaleFactor = 3
        window.layer.contentsScale = 3
        window.traitOverrides.layoutDirection = .leftToRight
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer {
            window.endEditing(true)
            window.isHidden = true
            window.rootViewController = nil
            previousWindow?.makeKeyAndVisible()
        }
        // The readiness loop yields to SwiftUI updates without a fixed startup delay.
        window.endEditing(true)
        settleControls(in: window)
        try await waitUntilReady(controller: controller, window: window, identifier: identifier, requiresAlert: verifiesAlert, requiresSheet: requiresSheet)
        if verifiesAlert {
            let alert = try XCTUnwrap(controller.presentedViewController as? UIAlertController)
            if verifiesRefreshAlert {
                XCTAssertEqual(alert.title, "Kunne ikke opdatere")
                XCTAssertEqual(alert.message, "Dine aktiviteter kunne ikke opdateres. Prøv igen.")
                XCTAssertEqual(alert.actions.map(\.title), ["Prøv igen", "Annuller"])
            } else {
                XCTAssertEqual(alert.title, "Login mislykkedes")
                XCTAssertEqual(alert.message, "Prøv at logge ind igen.")
                XCTAssertEqual(alert.actions.map(\.title), ["OK"])
            }
        }
        let pausedTime = window.layer.convertTime(CACurrentMediaTime(), from: nil)
        window.layer.speed = 0
        window.layer.timeOffset = pausedTime
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.preferredRange = .standard
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        var rendered = false
        let image = renderer.image { _ in
            rendered = window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        XCTAssertTrue(rendered, "The complete window hierarchy must render successfully")
        window.layer.speed = 1
        window.layer.timeOffset = 0
        controller.dismiss(animated: false)
        return image
    }

    @MainActor
    private func waitUntilReady(
        controller: UIViewController, window: UIWindow, identifier: String, requiresAlert: Bool, requiresSheet: Bool
    ) async throws {
        var previous: [CGRect] = []
        var stableFrames = 0
        // Three seconds is an upper bound, not a blanket delay on every screen.
        for _ in 0..<60 {
            window.layoutIfNeeded()
            controller.view.layoutIfNeeded()
            let presented = controller.presentedViewController
            let sheetReady = !requiresSheet || (
                presented != nil && presented?.view.window === window
                    && presented?.isBeingPresented == false && presented?.transitionCoordinator == nil
            )
            let presentationReady = sheetReady && (!requiresAlert || (
                presented is UIAlertController && presented?.view.window === window
                    && presented?.isBeingPresented == false && presented?.transitionCoordinator == nil
            ))
            let geometry = layoutFrames(in: window)
            if controller.view.window === window && controller.transitionCoordinator == nil && presentationReady {
                stableFrames = geometry == previous ? stableFrames + 1 : 0
                if stableFrames >= 2 { return }
            } else {
                stableFrames = 0
            }
            previous = geometry
            try await Task.sleep(for: .milliseconds(50))
        }
        throw CaptureReadinessError.notReady(identifier, requiresAlert ? "alert presentation" : (requiresSheet ? "sheet presentation" : "layout"))
    }

    @MainActor
    private func layoutFrames(in view: UIView) -> [CGRect] {
        guard !view.isHidden else { return [] }
        return [view.frame] + view.subviews.flatMap { layoutFrames(in: $0) }
    }

    @MainActor
    private func settleControls(in view: UIView) {
        if let picker = view as? UIPickerView {
            for component in 0..<picker.numberOfComponents {
                let row = picker.selectedRow(inComponent: component)
                if row >= 0 {
                    picker.selectRow(row, inComponent: component, animated: false)
                }
            }
        }
        if let scroll = view as? UIScrollView {
            scroll.setContentOffset(scroll.contentOffset, animated: false)
        }
        view.layoutIfNeeded()
        for child in view.subviews {
            settleControls(in: child)
        }
    }

}

@MainActor
private final class SnapshotWindow: UIWindow {
    override var safeAreaInsets: UIEdgeInsets {
        .init(top: 62, left: 0, bottom: 34, right: 0)
    }
}

private enum CaptureReadinessError: LocalizedError {
    case notReady(String, String)

    var errorDescription: String? {
        switch self {
        case let .notReady(identifier, phase):
            "Capture \(identifier) did not finish \(phase) within three seconds"
        }
    }
}
