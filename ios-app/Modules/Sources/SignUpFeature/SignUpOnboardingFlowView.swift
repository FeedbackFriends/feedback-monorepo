import SwiftUI
import ComposableArchitecture
import Domain
import DesignSystem

public struct SignUpOnboardingFlowView: View {
    
    @Bindable var store: StoreOf<SelectUserType>
    
    public init(store: StoreOf<SelectUserType>) {
        self.store = store
    }
    
    public var body: some View {
        let notificationPermissionPromptStore = $store.scope(
            state: \.destination?.notificationPermissionPrompt,
            action: \.destination.notificationPermissionPrompt
        )
        return NavigationStack {
            selectUserTypeView
                .navigationDestination(item: notificationPermissionPromptStore) { store in
                    NotificationPermissionView(
                        enablePushNotificationsButtonTap: {
                            store.send(.enablePushNotificationsButtonTap)
                        },
                        enableEmailsButtonTap: {
                            store.send(.enableEmailsButtonTap)
                        },
                        isLoading: store.isSubmitting
                    )
                    .navigationBarBackButtonHidden(true)
                }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

private extension SignUpOnboardingFlowView {
    var selectUserTypeView: some View {
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

private struct SignUpOnboardingFlowSheetPreview: View {
    
    let store: StoreOf<SelectUserType>
    @State private var isPresented = true
    
    var body: some View {
        Color.themeBackground
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                SignUpOnboardingFlowView(store: store)
                    .interactiveDismissDisabled()
                    .presentationDetents([.large])
            }
    }
}

#Preview("Sheet") {
    SignUpOnboardingFlowSheetPreview(
        store: .init(
            initialState: .init(),
            reducer: {
                SelectUserType()
            }
        )
    )
}
