import SwiftUI
import Foundation
import Domain

public struct ErrorView: View {
    
    let error: PresentableError
    let tryAgainButtonTapped: (() -> Void)?
    @Binding var isLoading: Bool
    
    private var exclamationmark: CGFloat { 40 }
    
    public init(
        error: PresentableError,
        isLoading: Binding<Bool>,
        tryAgainButtonTapped: (() -> Void)? = nil
    ) {
        self.error = error
        self._isLoading = isLoading
        self.tryAgainButtonTapped = tryAgainButtonTapped
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image.exlamationmarkCircleFill
                .resizable()
                .frame(width: exclamationmark, height: exclamationmark)
                .foregroundColor(.themeVerySad)
            
            Text("\(error.title) 💩")
                .font(.montserratBold, 16)
                .foregroundColor(.themeText)
            
            Text(error.message)
                .font(.montserratRegular, 13)
                .foregroundColor(.themeText)
                .multilineTextAlignment(.center)
            
            if let tryAgainButtonTapped {
                Button("Try again", action: tryAgainButtonTapped)
                    .buttonStyle(PrimaryTextButtonStyle())
                    .isLoading(isLoading)
                    .disabled(isLoading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 50)
    }
}
