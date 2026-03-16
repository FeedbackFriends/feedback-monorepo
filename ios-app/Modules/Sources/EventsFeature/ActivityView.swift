import Domain
import SwiftUI
import DesignSystem

public struct ActivityView: View {
    let activityItems: [ActivityItems]
    let activityManagerEventButtonTap: (ActivityItems) -> Void
    @Environment(\.dismiss) var dismiss
    
	public init(
		activityItems: [ActivityItems],
		activityManagerEventButtonTap: @escaping (ActivityItems) -> Void
	) {
        self.activityItems = activityItems
        self.activityManagerEventButtonTap = activityManagerEventButtonTap
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if activityItems.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "No activity yet",
                            message: "When new feedback comes in, activity updates will appear here."
                        )
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List {
                        Section {
                            
                            ForEach(activityItems.sorted(by: { $0.date > $1.date })) { item in
                                Button {
                                    activityManagerEventButtonTap(item)
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text("\(item.eventTitle)")
                                            .font(.montserratSemiBold, 14)
                                            .foregroundStyle(Color.themeText)
                                        Text("You have received \(item.newFeedbackCount) new feedback on ‘\(item.eventTitle)’.")
                                            .font(.montserratRegular, 12)
                                        HStack {
                                            if !item.seenByManager {
                                                Text("New")
                                                    .font(.montserratBold, 8)
                                                    .padding(2)
                                                    .padding(.horizontal, 4)
													.foregroundStyle(Color.themeOnPrimaryAction)
                                                    .background(Color.themeBlue)
                                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                                            }
                                            Text(item.date.timeAgo())
                                                .font(.montserratRegular, 10)
                                            Spacer()
                                            
                                        }
                                    }
									.foregroundStyle(Color.themeTextSecondary)
                                }
                            }
                        }
                    }
                    
                }
            }
            .foregroundStyle(Color.themeText)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ActivityView(
        activityItems: [],
        activityManagerEventButtonTap: { _ in }
    )
}
#Preview {
    ActivityView(
        activityItems: [
            .init(
                id: UUID(),
                date: Date(),
                eventTitle: "title1",
                eventId: UUID(),
                newFeedbackCount: 5,
                seenByManager: false
            ),
            .init(
                id: UUID(),
                date: Date(),
                eventTitle: "title2",
                eventId: UUID(),
                newFeedbackCount: 5,
                seenByManager: true
            )
        ],
        activityManagerEventButtonTap: { _ in }
    )
}
