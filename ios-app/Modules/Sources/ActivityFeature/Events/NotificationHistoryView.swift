import Localization
import Domain
import SwiftUI
import DesignSystem

public struct NotificationHistoryView: View {
    @Environment(\.referenceDate) private var referenceDate
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
                            title: String(appStrings: .notificationsEmptyTitle),
                            message: String(appStrings: .notificationsEmptyMessage)
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
                                            .rowTitleTextStyle()
                                            .foregroundStyle(Color.themeText)
                                        Text(String(appStrings: .notificationsReceivedFeedback(item.newFeedbackCount, item.eventTitle)))
                                            .supportingTextStyle()
                                        HStack {
                                            if !item.seenByManager {
                                                PillTagView(
                                                    String(appStrings: .commonNewBadge),
                                                    style: .compactBadge,
                                                    foregroundColor: .themeOnPrimaryAction,
                                                    backgroundColor: .themeBlue
                                                )
                                            }
                                            Text(L10n.Format.relativeTime(item.date, relativeTo: referenceDate ?? .now))
                                                .captionTextStyle()
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
            .navigationTitle(String(appStrings: .commonActivities))
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
