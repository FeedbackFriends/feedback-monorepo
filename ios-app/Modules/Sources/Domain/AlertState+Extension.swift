import ComposableArchitecture
import Foundation
import Localization

public extension AlertState {
    init(error: Error) {
        let presentation = error.localized
        self.init(
            title: { TextState(presentation.title) },
            actions: {
                ButtonState(role: .cancel, action: .send(.none)) { TextState(String(appStrings: .commonOk)) }
            },
            message: { TextState(presentation.message) }
        )
    }
}
