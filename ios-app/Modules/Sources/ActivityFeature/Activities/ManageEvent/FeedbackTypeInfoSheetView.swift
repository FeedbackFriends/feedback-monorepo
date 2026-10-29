import SwiftUI
import Domain
import DesignSystem

struct FeedbackTypeInfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FeedbackType.allCases, id: \.self) { type in
                        HStack(alignment: .top, spacing: 14) {
                            CircleIconView(type.image, size: 24, padding: 10)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(type.title)
                                    .rowTitleTextStyle()
                                Text(type.helpDescription)
                                    .supportingTextStyle()
                                    .foregroundStyle(Color.themeTextSecondary)
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(Color.themeSurface)
                    }
                } footer: {
                    Text("Vælg den svartype, der passer bedst til det spørgsmål, deltagerne skal svare på.")
                        .supportingTextStyle()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
            .background(Color.themeBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Svartyper")
            .navigationBarTitleDisplayMode(.large)
            .foregroundStyle(Color.themeText)
        }
        .presentationBackground(Color.themeBackground)
    }
}

#Preview {
    FeedbackTypeInfoSheetView()
}
