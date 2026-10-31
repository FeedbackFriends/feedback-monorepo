import DesignSystem
import SwiftUI

/// Matches Launch Screen.storyboard exactly on its first frame.
/// The ring is decorative and never delays entering the app.
struct StartupLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var ringIsVisible = false
    #if DEBUG
    @Environment(\.isScreenSnapshot) private var isScreenSnapshot
    #endif

    var body: some View {
        ZStack {
            Color.themeBackground

            TimelineView(.animation(minimumInterval: 1.0 / 60, paused: !animates)) { context in
                Circle()
                    .strokeBorder(
                        ringGradient,
                        lineWidth: 3.5
                    )
                    .background {
                        Circle()
                            .strokeBorder(ringGradient, lineWidth: 10)
                            .blur(radius: 12)
                            .opacity(0.5)
                    }
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(rotation(at: context.date)))
                    .scaleEffect(1 + 0.045 * pulse(at: context.date))
                    .opacity(0.8 + 0.2 * pulse(at: context.date))
            }
            .opacity(showsRing ? 1 : 0)

            // Same asset bytes, aspect-fit bounds and full-screen center as the storyboard.
            Image.letsGrowIcon
                .resizable()
                .scaledToFit()
                .frame(width: 124, height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lets Grow. Indlæser.")
        .accessibilityIdentifier("startup.loading")
        .task {
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.55)) {
                ringIsVisible = true
            }
        }
    }

    private var showsRing: Bool {
        #if DEBUG
        if isScreenSnapshot { return true }
        #endif
        return ringIsVisible
    }

    private var animates: Bool {
        #if DEBUG
        if isScreenSnapshot { return false }
        #endif
        return !reduceMotion && scenePhase == .active
    }

    private func rotation(at date: Date) -> Double {
        guard animates else { return 0 }
        return date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3.2) / 3.2 * 360
    }

    private func pulse(at date: Date) -> Double {
        guard animates else { return 0 }
        let phase = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 2.4) / 2.4
        return (1 - cos(phase * 2 * .pi)) / 2
    }

    private var ringGradient: AngularGradient {
        AngularGradient(
            colors: [
                .themePrimaryAction.opacity(0.12),
                .themePrimaryAction,
                .themeGradientBlue.opacity(0.85),
                .themeHappy.opacity(0.9),
                .themePrimaryAction.opacity(0.12)
            ],
            center: .center
        )
    }
}

#Preview("Startup · Dark") {
    StartupLoadingView()
        .preferredColorScheme(.dark)
}

#Preview("Startup · Still") {
    StartupLoadingView()
        .environment(\.isScreenSnapshot, true)
}
