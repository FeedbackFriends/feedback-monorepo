import DesignSystem
import SwiftUI

struct FeedbackElaborationTextField: View {
    
    @Binding var commentTextField: String
    @FocusState.Binding var commentTextfieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please elaborate why")
                .bodyTextStyle()
                .foregroundColor(.themeText)
            TextEditor(text: $commentTextField)
                .padding(.all, 12)
                .bodyTextStyle()
                .foregroundColor(.themeText)
                .scrollContentBackground(.hidden)
                .glassEffect(in: .rect(cornerRadius: Theme.cornerRadius))
                .focused($commentTextfieldFocused)
        }
        .transition(.blurReplace)
        .padding(.top, 8)
    }
}
