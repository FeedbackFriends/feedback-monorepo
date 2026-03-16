import SwiftUI

public enum BannerState: Equatable, Sendable {
    case offline(String)
    case serverError(String)
}

public extension View {
    
    /// Banner that shows offline or server error 'toast' style banner
    /// - Parameter enum: field controlling banner state
    /// - Returns: modified view
    func banner(unwrapping enum: BannerState?) -> some View {
        ZStack {
            self
            if let `enum` = `enum` {
                
                switch `enum` {
                case let .serverError(msg):
                    makeBanner(message: msg, color: .red)
                    
                case let .offline(msg):
                    makeBanner(message: msg, color: .orange)
                }
            }
        }
        .animation(.spring(duration: 0.8), value: `enum`)
        .sensoryFeedback(.success, trigger: `enum`)
    }
    
    func makeBanner(
        message: String,
        color: Color
    ) -> some View {
        VStack {
            Text(message)
                .font(.montserratRegular, 14)
                .padding(.horizontal, 50)
                .frame(minHeight: 54)
                .foregroundColor(Color.themeText)
                .cornerRadius(24)
				.glassEffect()
                .padding(.horizontal, 16)
                .padding(.top, 12)
            Spacer()
            
        }.zIndex(1)
            .transition(
                .move(edge: .top)
            )
    }
}

#Preview {
    @Previewable @State var bannerState: BannerState?
    
    VStack {
        Button("Trigger Banner") {
            bannerState = .serverError("Server is down!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                bannerState = nil
            }
        }
        Spacer()
    }
    .banner(unwrapping: bannerState)
    
}
