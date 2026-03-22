import SwiftUI
import ComposableArchitecture
import Domain
import DesignSystem

public struct SelectUserTypeView: View {
    
    @Bindable var store: StoreOf<SelectUserType>
    
    public init(store: StoreOf<SelectUserType>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What would you like to use the app for?")
                .padding(.top, 30)
                .font(.montserratBold, 14)
                .foregroundColor(.themeText)
            UserTypePickerView(selectedUserType: $store.selectedUserType)
            Button {
                store.send(.createAccountButtonTap)
            } label: {
                Text("Create account")
            }
            .buttonStyle(LargeButtonStyle())
            .isLoading(store.isLoading)
            .disabled(store.disableUserTypeSelectionButton)
            .padding(.bottom, 16)
        }
        .padding(.all, Theme.padding)
        .background(Color.themeBackground)
    }
}
