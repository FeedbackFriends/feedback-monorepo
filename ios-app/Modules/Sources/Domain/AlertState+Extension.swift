import ComposableArchitecture
import Foundation

public extension AlertState {
    init(error: Error) {
        
        let alert: AlertState<Action>
        
        var defaultErrorAlert: AlertState<Action> = AlertState(
            title: { TextState(error.localized.title) },
            message: { TextState(error.localized.message) }
        )
        defaultErrorAlert.buttons.append(ButtonState(role: .cancel, action: .send(.none), label: { TextState("Ok") }))
        alert = defaultErrorAlert
        self = alert
    }
}
