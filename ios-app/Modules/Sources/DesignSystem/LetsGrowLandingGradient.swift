import Foundation
import SwiftUI

public struct LetsGrowLandingGradient: View {
    public init () {}
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let minSide = min(size.width, size.height)

            ZStack {
                LinearGradient(
                    colors: gradientBaseColors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                GradientBlob(color: coralBlobColor)
                    .frame(width: minSide * 0.95, height: minSide * 0.72)
                    .position(x: size.width * 0.03, y: size.height * 0.02)

                GradientBlob(color: blueBlobColor)
                    .frame(width: minSide * 0.90, height: minSide * 0.78)
                    .position(x: size.width * 1.02, y: size.height * 0.08)

                GradientBlob(color: lilacBlobColor)
                    .frame(width: minSide * 1.00, height: minSide * 0.78)
                    .position(x: size.width * 0.52, y: size.height * 0.96)

                GradientBlob(color: goldBlobColor)
                    .frame(width: minSide * 0.92, height: minSide * 0.62)
                    .position(x: size.width * 0.80, y: size.height * 0.56)

                GradientBlob(color: greenBlobColor)
                    .frame(width: minSide * 0.70, height: minSide * 0.70)
                    .position(x: size.width * -0.05, y: size.height * 0.22)

                GradientBlob(color: skyBlobColor)
                    .frame(width: minSide * 0.85, height: minSide * 0.85)
                    .position(x: size.width * 1.05, y: size.height * 0.18)

                RadialGradient(
                    colors: radialHighlightColors,
                    center: .top,
                    startRadius: 0,
                    endRadius: size.height * 0.42
                )
            }
            .ignoresSafeArea()
        }
    }

    private var gradientBaseColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(hex: 0x020308),
                Color(hex: 0x0A0D14)
            ]
        default:
            return [
                Color(hex: 0xE8ECFA), // web: hsl(228 97% 97%)
                Color(hex: 0xF2F5F9)  // web: hsl(210 38% 98.4%)
            ]
        }
    }

    private var coralBlobColor: Color {
        colorScheme == .dark
            ? Color(hex: 0x2B120F).opacity(0.95)
            : Color(hex: 0xFD6349).opacity(0.20)
    }

    private var blueBlobColor: Color {
        colorScheme == .dark
            ? Color(hex: 0x0F1626).opacity(0.95)
            : Color(hex: 0x3D75F5).opacity(0.18)
    }

    private var lilacBlobColor: Color {
        colorScheme == .dark
            ? Color(hex: 0x1A1024).opacity(0.92)
            : Color(hex: 0x9D60E6).opacity(0.18)
    }

    private var goldBlobColor: Color {
        colorScheme == .dark
            ? Color(hex: 0x241A0B).opacity(0.92)
            : Color(hex: 0xFFAD33).opacity(0.12)
    }

    private var greenBlobColor: Color {
        colorScheme == .dark
            ? Color(hex: 0x071815).opacity(0.92)
            : Color(hex: 0x27AB85).opacity(0.14)
    }

    private var skyBlobColor: Color {
        colorScheme == .dark
            ? Color(hex: 0x08121B).opacity(0.92)
            : Color(hex: 0x7DD3FC).opacity(0.24)
    }

    private var radialHighlightColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                .white.opacity(0.025),
                .white.opacity(0.0)
            ]
        default:
            return [
                .white.opacity(0.30),
                .white.opacity(0.0)
            ]
        }
    }
}

private struct GradientBlob: View {
    let color: Color
    
    var body: some View {
        Ellipse()
            .fill(color)
            .blur(radius: 56)
            .allowsHitTesting(false)
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
