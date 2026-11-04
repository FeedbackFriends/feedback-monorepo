import Localization
import SwiftUI

public struct EventInfoView: View {
    
    let eventTitle: String
    let ownerName: String?
    let ownerEmail: String?
    let ownerphoneNumber: String?
    let date: Date
    
    public init(
        eventTitle: String,
        ownerName: String?,
        ownerEmail: String?,
        ownerphoneNumber: String?,
        date: Date
    ) {
        self.eventTitle = eventTitle
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.ownerphoneNumber = ownerphoneNumber
        self.date = date
    }
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(appStrings: .commonDate))
                        .rowTitleTextStyle()
                    Text(L10n.Format.date(date))
                        .supportingTextStyle()
                    if ownerName != nil || ownerEmail != nil || ownerphoneNumber != nil {
                        Text(String(appStrings: .sessionOwner))
                            .rowTitleTextStyle()
                        if let ownerName {
                            Text(ownerName)
                                .supportingTextStyle()
                        }
                        if let ownerEmail {
                            Text(ownerEmail)
                                .supportingTextStyle()
                        }
                        if let ownerphoneNumber {
                            Text(ownerphoneNumber)
                                .supportingTextStyle()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
				.foregroundColor(Color.themeText)
                .padding(.all, Theme.padding)
                .background(
                    Color.themeSurface
                        .cornerRadius(Theme.cornerRadius)
                )
                .padding(.all, Theme.padding)
            }
            .lineSpacing(7)
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(eventTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
        }
        .presentationBackground(Color.themeBackground)
    }
}

#Preview("All data") {
    EventInfoView(
        eventTitle: "Titel",
        ownerName: "Owner name",
        ownerEmail: "Owner email",
        ownerphoneNumber: "Owner phone",
        date: Date()
    )
}

#Preview("Some owner data") {
    EventInfoView(
        eventTitle: "Titel",
        ownerName: "Owner name",
        ownerEmail: nil,
        ownerphoneNumber: nil,
        date: Date()
    )
}

#Preview("No owner data") {
    EventInfoView(
        eventTitle: "Titel",
        ownerName: nil,
        ownerEmail: nil,
        ownerphoneNumber: nil,
        date: Date()
    )
}
