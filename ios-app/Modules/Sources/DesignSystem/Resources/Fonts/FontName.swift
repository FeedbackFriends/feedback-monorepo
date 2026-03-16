import Foundation
import SwiftUI
import UIKit

public extension Font {
    enum FontName: String, CaseIterable, Identifiable {
        public var id: String {
            "\(self)"
        }
        case montserratBlack = "Montserrat-Black"
        case montserratBold = "Montserrat-Bold"
        case montserratExtraBold = "Montserrat-ExtraBold"
        case montserratExtraLight = "Montserrat-ExtraLight"
        case montserratItalic = "Montserrat-Italic"
        case montserratMedium = "Montserrat-Medium"
        case montserratRegular = "Montserrat-Regular"
        case montserratSemiBold = "Montserrat-SemiBold"
        case montserratThin = "Montserrat-Thin"
    }
}
