import SwiftUI

struct LightShadow: ViewModifier {
    var color: Color = .black
    var opacity: Double = 0.08
    var radius: CGFloat = 2
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity), radius: radius)
    }
}

extension View {
    public func lightShadow(color: Color = .black, opacity: Double = 0.08, radius: CGFloat = 2) -> some View {
        self.modifier(LightShadow(color: color, opacity: opacity, radius: radius))
    }
}
