import SwiftUI

public struct EventInfoView: View {
    
    let eventTitle: String
    let eventAgenda: String?
    let ownerName: String?
    let ownerEmail: String?
    let ownerphoneNumber: String?
    let date: Date
    
    public init(
        eventTitle: String,
        eventAgenda: String?,
        ownerName: String?,
        ownerEmail: String?,
        ownerphoneNumber: String?,
        date: Date
    ) {
        self.eventTitle = eventTitle
        self.eventAgenda = eventAgenda
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
                    if let eventAgenda {
                        Text("Agenda")
                            .padding(.top, 8)
                            .rowTitleTextStyle()
                        Text(eventAgenda)
                            .supportingTextStyle()
                    }
                    Text("Date")
                        .rowTitleTextStyle()
                    Text(date.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: .omitted))
                        .supportingTextStyle()
                    if ownerName != nil || ownerEmail != nil || ownerphoneNumber != nil {
                        Text("Organizer")
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
    }
}

#Preview("All data") {
    EventInfoView(
        eventTitle: "Title",
        eventAgenda: "Agenda",
        ownerName: "Owner name",
        ownerEmail: "Owner email",
        ownerphoneNumber: "Owner phone",
        date: Date()
    )
}

#Preview("Some owner data") {
    EventInfoView(
        eventTitle: "Title",
        eventAgenda: "Agenda",
        ownerName: "Owner name",
        ownerEmail: nil,
        ownerphoneNumber: nil,
        date: Date()
    )
}

#Preview("No owner data") {
    EventInfoView(
        eventTitle: "Title",
        eventAgenda: "Agenda",
        ownerName: nil,
        ownerEmail: nil,
        ownerphoneNumber: nil,
        date: Date()
    )
}
