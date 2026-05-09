import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
extension UIFont {
    static func register(from url: URL) throws {
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        guard success else {
            throw error!.takeUnretainedValue()
        }
    }
}
#endif

func fontsURLs() -> [URL] {
    Font.FontName
        .allCases
        .map(\.rawValue)
        .map {
            Bundle.module.url(forResource: $0, withExtension: "otf")
        }.compactMap { $0 }
}

#if canImport(UIKit)
public extension UIFont {
    static func font(_ name: Font.FontName, _ size: CGFloat) -> UIFont {
        _ = _FontRegistrar.once
        return UIFont(name: name.rawValue, size: size)!
    }
}
#endif

public extension View {
    func font(_ name: Font.FontName, _ size: CGFloat) -> some View {
        #if canImport(UIKit)
        _ = _FontRegistrar.once
        #endif
        return font(.custom(name.rawValue, size: size))
    }
}

private enum _FontRegistrar {
    static let once: Void = {
        #if canImport(UIKit)
        do {
            try fontsURLs().forEach { try UIFont.register(from: $0) }
        } catch {
            assertionFailure("Failed to register fonts: \(error)")
        }
        #endif
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
