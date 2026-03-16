import SwiftUI

struct FadeInOutOnChange<T: Equatable>: ViewModifier {
    @State private var opacity: Double = 1
    let trigger: T
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onChange(of: trigger) { _, _ in
//                withAnimation(.snappy) {
                    opacity = 0
//                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.smooth) {
                        opacity = 1
                    }
                }
            }
    }
}

public extension View {
    func fadeInOut<T: Equatable>(onChangeOf trigger: T, delay: Double = 0.5) -> some View {
        self.modifier(FadeInOutOnChange(trigger: trigger, delay: delay))
    }
}
