import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    
    let lottieFile: LottieFile
    let loopMode: Bool
    let animationView = LottieAnimationView()
    
    public init(lottieFile: LottieFile, loopMode: Bool = false) {
        self.lottieFile = lottieFile
        self.loopMode = loopMode
    }
    
    public func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = LottieAnimation.named(lottieFile.rawValue, bundle: .module)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode ? .loop : .playOnce
        animationView.animationSpeed = 0.5
        animationView.play()
        
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    LottieView(lottieFile: .loading)
        .frame(width: 300, height: 300)
}
