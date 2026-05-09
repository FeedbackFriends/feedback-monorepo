import Domain
import SwiftUI
import DesignSystem

public struct NotificationHistoryView: View {
    let notificationHistoryItems: [NotificationHistoryItem]
    let activityManagerEventButtonTap: (NotificationHistoryItem) -> Void
    @Environment(\.dismiss) var dismiss
    
	public init(
        notificationHistoryItems: [NotificationHistoryItem],
		activityManagerEventButtonTap: @escaping (NotificationHistoryItem) -> Void
	) {
        self.notificationHistoryItems = notificationHistoryItems
        self.activityManagerEventButtonTap = activityManagerEventButtonTap
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if notificationHistoryItems.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "Nothing to show here yet.",
                            message: "Once there’s an update, you’ll see it here."
                        )
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List {
                        Section {
                            
                            ForEach(notificationHistoryItems.sorted(by: { $0.date > $1.date })) { item in
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
    NotificationHistoryView(
        notificationHistoryItems: [],
        activityManagerEventButtonTap: { _ in }
    )
}
#Preview {
    NotificationHistoryView(
        notificationHistoryItems: [
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
