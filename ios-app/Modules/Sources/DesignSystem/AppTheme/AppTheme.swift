import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct AppTheme {
    @MainActor
    public static func setUp() {
        #if canImport(UIKit)
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
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.themeOnPrimaryAction

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
        #endif
    }
}
