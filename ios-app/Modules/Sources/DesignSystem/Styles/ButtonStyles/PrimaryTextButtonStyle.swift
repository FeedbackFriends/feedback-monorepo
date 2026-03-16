import SwiftUI

public struct PrimaryTextButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isLoading) private var isLoading
    private let color: Color
	
	var foregroundColor: Color {
		isEnabled ? color : Color.themeText.opacity(0.5)
	}
    
    public init(color: Color = Color.themePrimaryAction) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
           Group {
               if isLoading {
                   ProgressView()
               } else {
                   configuration.label
                       .font(.montserratBold, 15)
                       .foregroundStyle(Color.themePrimaryAction)
                       .lineLimit(1)
                       .padding(.horizontal, 14)
                       .padding(.vertical, 8)
               }
           }
           .scaleEffect(configuration.isPressed ? 1.03 : 1.0)
           .opacity(isEnabled ? 1 : 0.4)
           .progressViewStyle(.circular)
           .fixedSize()
           .progressViewStyle(CircularProgressViewStyle(tint: Color.themeText))
       }
}

#Preview {
    NavigationStack {
        Text("")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enabled") {
                        
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Disabled") {
                        
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(true)
                }
                .sharedBackgroundVisibility(.hidden)
            }
    }
}
