import SwiftUI

public struct ProfileAvatarView: View {
    private let name: String?
    private let size: CGFloat

    public init(name: String?, size: CGFloat = 28) {
        self.name = name
        self.size = size
    }

    public static func initials(for name: String?) -> String? {
        let words = (name ?? "").split(whereSeparator: \.isWhitespace)
        guard let first = words.first?.first else { return nil }
        let last = words.count > 1 ? words.last?.first.map(String.init) ?? "" : ""
        return (String(first) + last).uppercased()
    }

    public var body: some View {
        Group {
            if let initials = Self.initials(for: name) {
                Text(verbatim: initials)
                    .rowTitleTextStyle()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(4)
            } else {
                Image.personCircleFill
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(Color.themeText)
        .background(Color.themeSurfaceSecondary, in: Circle())
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
