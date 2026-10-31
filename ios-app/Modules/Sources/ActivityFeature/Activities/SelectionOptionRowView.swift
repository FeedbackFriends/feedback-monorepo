import SwiftUI
import DesignSystem

struct SelectionOptionRowView: View {
    let title: String
    let subtitle: String
    let icon: Image
    let isSelected: Bool
    let accessibilityIdentifier: String?
    let onTap: () -> Void

    init(
        title: String,
        subtitle: String,
        icon: Image,
        isSelected: Bool,
        accessibilityIdentifier: String? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.accessibilityIdentifier = accessibilityIdentifier
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isSelected ? Color.themePrimaryAction : Color.themeTextSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .rowTitleTextStyle()
                        .foregroundStyle(Color.themeText)
                    Text(subtitle)
                        .supportingTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                }

                Spacer()

                Group {
                    if isSelected {
                        Image.checkmarkCircleFill
                    } else {
                        Image.circle
                    }
                }
                .foregroundStyle(isSelected ? Color.themePrimaryAction : Color.themeTextSecondary)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeBackground)
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(isSelected ? Color.themePrimaryAction : Color.clear, lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .buttonStyle(ScalingButtonStyle())
        .multilineTextAlignment(.leading)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
