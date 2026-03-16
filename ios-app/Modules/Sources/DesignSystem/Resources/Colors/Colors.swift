import Foundation
import SwiftUI
import UIKit

public struct Theme {
	public static let cornerRadius = 18.0
	public static let padding = 18.0
}

public extension Color {
	static let themeSad = Color("themeSad", bundle: Bundle.module)
	static let themeHappy = Color("themeHappy", bundle: Bundle.module)
	static let themeVerySad = Color("themeVerySad", bundle: Bundle.module)
	static let themeVeryHappy = Color("themeVeryHappy", bundle: Bundle.module)
	static let themeSuccess = Color("themeVeryHappy", bundle: Bundle.module)
	static let themeBlue = Color("themeBlue", bundle: Bundle.module)
	static let themePrimaryAction = Color("primaryAction", bundle: Bundle.module)
	static let themeOnPrimaryAction = Color("onPrimaryAction", bundle: Bundle.module)
	static let themeBackground = Color("background", bundle: Bundle.module)
	static let themeSurface = Color("surface", bundle: Bundle.module)
	static let themeSurfaceSecondary = Color("surfaceSecondary", bundle: Bundle.module)
	static let themeText = Color("text", bundle: Bundle.module)
	static let themeTextSecondary = Color("textSecondary", bundle: Bundle.module)
    static let themeGradientRed = Color("themeGradientRed", bundle: Bundle.module)
    static let themeGradientBlue = Color("themeGradientBlue", bundle: Bundle.module)
    static let themeChartHighlighted = Color("themeChartHighlighted", bundle: Bundle.module)
    static let themeChartBackground = Color("themeChartBackground", bundle: Bundle.module)
    static let themeHoverOverlay = Color("themeHoverOverlay", bundle: Bundle.module)
}

public extension UIColor {
	static var themeText: UIColor { return UIColor(.themeText) }
	static var themeBackground: UIColor { return UIColor(.themeBackground) }
}
