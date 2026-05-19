import SwiftUI
import Domain
import DesignSystem

struct FeedbackTypeInfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List(FeedbackType.allCases, id: \.self) { type in
                HStack(alignment: .top, spacing: 12) {
                    type.image
                        .font(.title3)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.title)
                            .font(.montserratSemiBold, 15)
                        Text(type.helpDescription)
                            .font(.montserratRegular, 13)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
            .background(Color.themeBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Feedback types")
            .navigationBarTitleDisplayMode(.large)
            .foregroundStyle(Color.themeText)
        }
    }
}

#Preview {
    FeedbackTypeInfoSheetView()
}
