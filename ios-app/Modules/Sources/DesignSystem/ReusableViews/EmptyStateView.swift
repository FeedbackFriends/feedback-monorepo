import SwiftUI

public struct EmptyStateView: View {
    
    let title: String
    let message: String
    
    public init(title: String = "Nothing here yet.", message: String) {
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image.rectangeOnRectangle
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.themeTextSecondary)
            VStack(spacing: 6) {
                Text(title)
                    .font(.montserratExtraBold, 18)
                Text(message)
                    .font(.montserratRegular, 14)
                    .multilineTextAlignment(.center)
            }
        }
		.foregroundColor(.themeText)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 50)
        .padding(.top, 50)
    }
}

#Preview {
    EmptyStateView(
        message: "Message bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla"
    )
}
