import SwiftUI

public enum SyncIndicatorPhase: Equatable, Sendable {
    case idle, syncing, success
}

public struct SyncIndicatorView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if DEBUG
    @Environment(\.isScreenSnapshot) private var isScreenSnapshot
    #endif
    private let phase: SyncIndicatorPhase

    public init(phase: SyncIndicatorPhase) {
        self.phase = phase
    }

    private var usesStaticPresentation: Bool {
        #if DEBUG
        if isScreenSnapshot { return true }
        #endif
        return reduceMotion
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.themeSurfaceSecondary)
                if phase == .success {
                    Capsule().fill(Color.themeSuccess)
                } else if phase == .syncing {
                    if usesStaticPresentation {
                        Capsule().fill(Color.themeBlue)
                    } else {
                        TimelineView(.animation) { context in
                            let progress = context.date.timeIntervalSinceReferenceDate
                                .truncatingRemainder(dividingBy: 1.2) / 1.2
                            Capsule()
                                .fill(Color.themeBlue)
                                .frame(width: geometry.size.width * 0.25)
                                .offset(x: (geometry.size.width * 1.25 * progress) - geometry.size.width * 0.25)
                        }
                    }
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 4)
        .opacity(phase == .idle ? 0 : 1)
        .animation(.easeInOut(duration: reduceMotion ? 0 : 0.2), value: phase)
        .accessibilityHidden(true)
    }
}
