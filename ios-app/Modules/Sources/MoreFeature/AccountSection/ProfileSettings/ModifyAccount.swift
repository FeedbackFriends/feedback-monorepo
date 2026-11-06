import SwiftUI
import ComposableArchitecture
import Domain

@Reducer
public struct ModifyAccount: Sendable {
    
    @Reducer
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Presents var destination: Destination.State?
        var nameInput: String
        var emailInput: String
        var phoneNumberInput: String
        var isLoading = false
    }
    
    public enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case presentError(Error)
        case saveButtonTap
        case updateAccountResponse
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .binding:
                return .none
                
            case .presentError(let error):
                state.isLoading = false
                state.destination = .alert(
                    .init(error: error)
                )
                return .none
                
            case .destination:
                return .none
                
            case .saveButtonTap:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .run { [state = state] send in
                    do {
                        _ = try await self.apiClient.modifyAccount(
                            name: state.nameInput,
                            email: state.emailInput,
                            phoneNumber: Self.e164PhoneNumber(from: state.phoneNumberInput)
                        )
                        await send(.updateAccountResponse)
                    } catch {
                        await send(.presentError(error))
                    }
                }
                
            case .updateAccountResponse:
                state.isLoading = false
                return .run { _ in
                    await dismiss()
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    static func e164PhoneNumber(from input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let digits = trimmed.filter(\.isNumber)
        if trimmed.hasPrefix("+") {
            return "+" + digits
        }
        let nationalNumber = digits.hasPrefix("0") ? String(digits.dropFirst()) : digits
        return nationalNumber.isEmpty ? nil : "+45" + nationalNumber
    }
}

extension ModifyAccount.Destination.State: Equatable, Sendable {}
