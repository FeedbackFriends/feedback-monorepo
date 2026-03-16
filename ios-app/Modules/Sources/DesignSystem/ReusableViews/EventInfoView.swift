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
                            .font(.montserratBold, 15)
                        Text(eventAgenda)
                            .font(.montserratRegular, 13)
                    }
                    Text("Date")
                        .font(.montserratBold, 15)
                    Text(date.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: .omitted))
                        .font(.montserratRegular, 13)
                    if ownerName != nil || ownerEmail != nil || ownerphoneNumber != nil {
                        Text("Organizer")
                            .font(.montserratBold, 15)
                        if let ownerName {
                            Text(ownerName)
                                .font(.montserratRegular, 13)
                        }
                        if let ownerEmail {
                            Text(ownerEmail)
                                .font(.montserratRegular, 13)
                        }
                        if let ownerphoneNumber {
                            Text(ownerphoneNumber)
                                .font(.montserratRegular, 13)
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
