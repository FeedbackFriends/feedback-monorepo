import DesignSystem
import SwiftUI

struct FeedbackElaborationTextField: View {
    
    @Binding var commentTextField: String
    @FocusState.Binding var commentTextfieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please elaborate why")
                .font(.montserratMedium, 14)
                .foregroundColor(.themeText)
            TextEditor(text: $commentTextField)
                .padding(.all, 12)
                .font(.montserratRegular, 14)
                .foregroundColor(.themeText)
                .scrollContentBackground(.hidden)
                .glassEffect(in: .rect(cornerRadius: Theme.cornerRadius))
                .focused($commentTextfieldFocused)
        }
        .transition(.blurReplace)
        .padding(.top, 8)
    }
}
