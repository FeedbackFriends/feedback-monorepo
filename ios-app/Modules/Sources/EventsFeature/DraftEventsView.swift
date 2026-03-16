import Domain
import SwiftUI
import DesignSystem

public struct DraftEventsView: View {
    let draftEvents: [ManagerEvent]
    let draftEventButtonTap: (ManagerEvent) -> Void
    @Environment(\.dismiss) var dismiss
    
    public init(
        draftEvents: [ManagerEvent],
        draftEventButtonTap: @escaping (ManagerEvent) -> Void
    ) {
        self.draftEvents = draftEvents
        self.draftEventButtonTap = draftEventButtonTap
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if draftEvents.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            title: "No draft sessions yet",
                            message: "Draft sessions will appear here after you add feedback@letsgrow.dk to a calendar invite."
                        )
                        .frame(maxWidth: Constants.maxWidthForLargeDevices)
                        .padding(.horizontal, Theme.padding)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List {
                        Section {
                            ForEach(draftEvents.sorted(by: { $0.date > $1.date })) { item in
                                Button {
                                    draftEventButtonTap(item)
                                    dismiss()
                                } label: {
                                    draftEventRow(item)
                                }
                                .buttonStyle(OpacityButtonStyle())
                                .listRowInsets(EdgeInsets(top: 6, leading: Theme.padding, bottom: 6, trailing: Theme.padding))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .foregroundStyle(Color.themeText)
            .navigationTitle("Drafts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { dismiss() }
                }
            }
            .background(Color.themeBackground)
        }
    }
}

private extension DraftEventsView {
    struct ProviderBadgeConfig {
        let image: Image
        let tint: Color?
        let label: String
    }

    func draftEventRow(_ item: ManagerEvent) -> some View {
        HStack(spacing: 12) {
            providerBadge(item.calendarProvider)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.montserratSemiBold, 14)
                    .foregroundStyle(Color.themeText)
                HStack(spacing: 8) {
                    Text(item.formattedDate)
                        .font(.montserratRegular, 11)
                        .foregroundStyle(Color.themeTextSecondary)
                    if let providerName = providerDisplayName(item.calendarProvider) {
                        Text(providerName)
                            .font(.montserratSemiBold, 11)
                            .foregroundStyle(Color.themeTextSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.themeSurface)
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer()
            Image.chevronRight
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundColor(.themeText.opacity(0.8))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Color.themeSurface)
        )
        .lightShadow()
    }
    
    func providerBadge(_ provider: CalendarProvider?) -> some View {
        let config = providerBadgeConfig(provider)
        return ZStack {
            if #available(iOS 26.0, *) {
                Circle()
                    .fill(Color.clear)
                    .glassEffect()
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
            }
            if let tint = config.tint {
                config.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(tint)
            } else {
                config.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
        .frame(width: 34, height: 34)
        .overlay(Circle().stroke((config.tint ?? Color.themeTextSecondary).opacity(0.2), lineWidth: 1))
    }
    
    func providerDisplayName(_ provider: CalendarProvider?) -> String? {
        guard let provider else { return nil }
        switch provider {
        case .APPLE:
            return "Apple"
        case .GOOGLE:
            return "Google"
        case .MICROSOFT:
            return "Microsoft"
        case .ZOOM:
            return "Zoom"
        }
    }
    
    func providerBadgeConfig(_ provider: CalendarProvider?) -> ProviderBadgeConfig {
        guard let provider else {
            return ProviderBadgeConfig(
                image: Image.calendar,
                tint: Color.themeTextSecondary,
                label: "Calendar"
            )
        }
        switch provider {
        case .APPLE:
            return ProviderBadgeConfig(image: Image.iconApple, tint: Color.themeText, label: "Apple Calendar")
        case .GOOGLE:
            return ProviderBadgeConfig(image: Image.iconGoogle, tint: nil, label: "Google Calendar")
        case .MICROSOFT:
            return ProviderBadgeConfig(image: Image.iconMicrosoft, tint: nil, label: "Microsoft Outlook")
        case .ZOOM:
            return ProviderBadgeConfig(image: Image(systemName: "video.fill"), tint: Color.themeBlue, label: "Zoom")
        }
    }
}

#Preview {
    DraftEventsView(
        draftEvents: [],
        draftEventButtonTap: { _ in }
    )
}

#Preview {
    DraftEventsView(
        draftEvents: [
            ManagerEvent.mock()
        ],
        draftEventButtonTap: { _ in }
    )
}
