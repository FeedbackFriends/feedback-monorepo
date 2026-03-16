import Foundation
import SwiftUI
import UIKit

public struct AppTheme {
	@MainActor
	public static func setUp() {
		let transAppearence = UINavigationBarAppearance()
		transAppearence.largeTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.themeText,
			NSAttributedString.Key.font: UIFont.font(.montserratBold, 27)
		]
		transAppearence.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.themeText,
			NSAttributedString.Key.font: UIFont.font(.montserratBold, 16)
		]
		UISegmentedControl.appearance().setTitleTextAttributes(
			[
				NSAttributedString.Key.foregroundColor: UIColor.themeText,
				NSAttributedString.Key.font: UIFont.font(.montserratMedium, 12)
			],
			for: UIControl.State.normal
		)
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
		
		UIBarButtonItem.appearance().setTitleTextAttributes(
			[
				NSAttributedString.Key.foregroundColor: UIColor.themeText,
				NSAttributedString.Key.font: UIFont.font(.montserratMedium, 15)
			],
			for: UIControl.State.normal
		)
		UINavigationBar.appearance().standardAppearance = transAppearence
		UINavigationBar.appearance().scrollEdgeAppearance = transAppearence
		UINavigationBar.appearance().compactAppearance = transAppearence
		UINavigationBar.appearance().compactScrollEdgeAppearance = transAppearence
	}
}
