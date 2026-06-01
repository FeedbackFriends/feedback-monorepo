import Foundation
import SwiftUI

public extension Image {
    
    static let iconGoogle = Image("icon_google", bundle: Bundle.module)
    static let iconFacebook = Image("icon_facebook", bundle: Bundle.module)
    static let iconApple = Image(systemName: "applelogo")
    static let iconMicrosoft = Image("icon_Microsoft", bundle: Bundle.module)
    static let calendarAppleLogo = Image("apple_logo", bundle: Bundle.module)
    static let calendarGoogle = Image("google_calendar", bundle: Bundle.module)
    static let calendarMicrosoftOutlook = Image("microsoft_outlook", bundle: Bundle.module)
    static let calendarProton = Image("proton-calendar", bundle: Bundle.module)
    static let calendarTeamsLogo = Image("teams_logo", bundle: Bundle.module)
    static let calendarZoho = Image("zoho_calendar", bundle: Bundle.module)
    static let verySad = Image("verySad", bundle: Bundle.module)
    static let sad = Image("sad", bundle: Bundle.module)
    static let happy = Image("happy", bundle: Bundle.module)
    static let veryHappy = Image("veryHappy", bundle: Bundle.module)
    static let letsGrowIconTab = Image("letsGrowIconTab", bundle: Bundle.module)
    static let letsGrowIcon = Image("letsGrowIcon", bundle: Bundle.module)
    static let signUpIcon = Image("signup_icon", bundle: Bundle.module)
    static let letsGrowText = Image("letsGrowText", bundle: Bundle.module)
    
    static let thumpsUp = Image(systemName: "hand.thumbsup.fill")
    static let thumpsDown = Image(systemName: "hand.thumbsdown.fill")
    static let circleFill = Image(systemName: "circle.fill")
    static let plus = Image(systemName: "plus")
    static let lockFill = Image(systemName: "lock.fill")
    static let questionmarkCircle = Image(systemName: "questionmark")
    static let plusCircleFill = Image(systemName: "plus.circle.fill")
    static let info = Image(systemName: "info")
    static let arrowBackwards = Image(systemName: "arrow.backward")
    static let personCircleFill = Image(systemName: "person.circle.fill")
    static let chevronRight = Image(systemName: "chevron.right")
    static let heartFill = Image(systemName: "heart.fill")
    static let checkmarkCircleFill = Image(systemName: "checkmark.circle.fill")
    static let calendar = Image(systemName: "calendar")
    static let personCropCircle = Image(systemName: "person.crop.circle")
    static let sparkles = Image(systemName: "sparkles")
    static let feedbackTypeEmoji = Image(systemName: "face.smiling")
    static let feedbackTypeComment = Image(systemName: "text.bubble")
    static let feedbackTypeThumpsUpThumpsDown = Image(systemName: "hand.thumbsup")
    static let feedbackTypeOpinion = Image(systemName: "quote.bubble")
    static let feedbackTypeZeroToTen = Image(systemName: "number")
    static let circle = Image(systemName: "circle")
    static let clockBadgeXmark = Image(systemName: "clock.badge.xmark")
    static let documentOnDocument = Image(systemName: "document.on.document")
    static let squareAndArrowUp = Image(systemName: "square.and.arrow.up")
    static let xmark = Image(systemName: "xmark")
    static let chevronCompactDown = Image(systemName: "chevron.compact.down")
    static let rectangeOnRectangle = Image(systemName: "rectangle.on.rectangle")
    static let exlamationmarkCircleFill = Image(systemName: "exclamationmark.circle.fill")
    static let xmarkCircleFill = Image(systemName: "xmark.circle.fill")
    static let playButton = Image(systemName: "play.circle")
    
    static let moreSectionBell = Image(systemName: "bell")
    static let moreSectiondocPlaintext = Image(systemName: "doc.plaintext")
    static let moreSectionElipsisBubble = Image(systemName: "ellipsis.bubble")
    static let moreSectionExlamaionmarkSquare = Image(systemName: "exclamationmark.square")
    static let moreSectionPortraitAndArrowRight = Image(systemName: "rectangle.portrait.and.arrow.right")
    static let moreSectionTrash = Image(systemName: "trash")
    static let moreSectionPersonBadgeKey = Image(systemName: "person.badge.key")
    static let settings = Image(systemName: "gearshape.fill")

    static var copyActionIcon: some View {
        documentOnDocument.sizedSymbol(16)
    }

    static var shareActionIcon: some View {
        squareAndArrowUp.sizedSymbol(14)
    }

    static var expiredStatusIcon: some View {
        clockBadgeXmark.sizedSymbol(14)
    }

    static var clearSelectionIcon: some View {
        xmark.sizedSymbol(12)
    }

    static var thumpsUpFeedbackIcon: some View {
        thumpsUp.sizedSymbol(34)
    }

    static var thumpsDownFeedbackIcon: some View {
        thumpsDown.sizedSymbol(34)
    }

    static func onboardingIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .sizedSymbol(64)
    }

    static var firstFocusOnboardingIcon: some View {
        Image(systemName: "leaf.fill")
            .sizedSymbol(50)
    }
    
}

private extension Image {
    func sizedSymbol(_ size: CGFloat) -> some View {
        font(.system(size: size))
    }
}
