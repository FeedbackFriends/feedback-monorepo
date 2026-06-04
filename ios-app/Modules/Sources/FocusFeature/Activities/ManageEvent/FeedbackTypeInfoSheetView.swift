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
                            type.image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.themePrimaryAction)
                                .padding(10)
                                .background(Color.themePrimaryAction.opacity(0.12))
                                .clipShape(Circle())
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
    }
}

#Preview {
    FeedbackTypeInfoSheetView()
}
