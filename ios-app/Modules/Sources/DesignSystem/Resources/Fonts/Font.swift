import Foundation
import SwiftUI
import UIKit

extension UIFont {
	static func register(from url: URL) throws {
		var error: Unmanaged<CFError>?
		let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
		guard success else {
			throw error!.takeUnretainedValue()
		}
	}
}

func fontsURLs() -> [URL] {
	Font.FontName
		.allCases
		.map(\.rawValue)
		.map {
			Bundle.module.url(forResource: $0, withExtension: "otf")
		}.compactMap { $0 }
}

public extension UIFont {
	static func font(_ name: Font.FontName, _ size: CGFloat) -> UIFont {
        _ = _FontRegistrar.once
		return UIFont(name: name.rawValue, size: size)!
	}
}

public extension View {
	func font(_ name: Font.FontName, _ size: CGFloat) -> some View {
        _ = _FontRegistrar.once
		return font(.custom(name.rawValue, size: size))
	}
}

private enum _FontRegistrar {
    static let once: Void = {
        do {
            try fontsURLs().forEach { try UIFont.register(from: $0) }
        } catch {
            assertionFailure("Failed to register fonts: \(error)")
        }
    }()
}

#Preview {
	ScrollView {
		VStack {
			ForEach(Font.FontName.allCases) {
				Text("\($0)" as String).font($0, 12)
			}
		}
		.environment(\.sizeCategory, .accessibilityExtraExtraLarge)
	}
}
