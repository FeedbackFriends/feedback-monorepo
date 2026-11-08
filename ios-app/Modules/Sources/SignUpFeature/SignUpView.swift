import Localization
import Foundation
import SwiftUI
import ComposableArchitecture
import DesignSystem
import Domain

public struct SignUpView: View {
    
    private let onProfileButtonTap: (() -> Void)?
    @Bindable var store: StoreOf<SignUp>
    
    public init(store: StoreOf<SignUp>, onProfileButtonTap: (() -> Void)? = nil) {
        self.store = store
        self.onProfileButtonTap = onProfileButtonTap
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
            VStack(spacing: 40) {
                Spacer()
                Image.letsGrowIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .accessibilityIdentifier("sign_up_logo")
                    .onTapGesture(count: 10) {
                        store.send(.iconTenTimesTap)
                    }
                    #if DEBUG
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            store.send(.e2eAuthenticationIconTap)
                        }
                    )
                    #endif
                Spacer()
                signUpView
            }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                if let onProfileButtonTap {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onProfileButtonTap) {
                            ProfileAvatarView(name: nil)
                        }
                            .accessibilityLabel(String(appStrings: .commonProfile))
                            .accessibilityIdentifier("profile_button")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .background(LetsGrowLandingGradient())
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            #if DEBUG
            .sheet(
                isPresented: .init(
                    get: { store.e2eAuthenticationSheetPresented },
                    set: { isPresented in
                        if !isPresented {
                            store.send(.e2eAuthenticationSheetDismissed)
                        }
                    }
                )
            ) {
                E2EAuthenticationDebugView(store: store)
            }
            #endif
        }
    }
}

private extension SignUpView {
    var signUpView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(String(appStrings: .signInTitle))
                .largeTitleTextStyle()
                .foregroundStyle(Color.themeText.gradient)
            Text(String(appStrings: .signInExplanation))
                .bodyTextStyle()
                .foregroundColor(.themeText)
            TextField(String(appStrings: .signInWorkEmail), text: $store.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .disabled(store.loginInFlight || store.emailCodeSent)
                .accessibilityLabel(String(appStrings: .signInWorkEmail))
            if store.emailCodeSent {
                TextField(String(appStrings: .signInEmailCode), text: $store.emailCode)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .disabled(store.loginInFlight)
                    .accessibilityLabel(String(appStrings: .signInEmailCode))
            }
            if let status = store.emailStatus {
                Text(status).captionTextStyle().accessibilityAddTraits(.updatesFrequently)
            }
            Button(String(appStrings: store.emailCodeSent ? .signInVerifyCode : .signInSendCode)) {
                store.send(.emailContinueTap)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.themeText, foregroundColor: Color.themeBackground))
            .disabled(store.loginInFlight || store.email.isEmpty || (store.emailCodeSent && store.emailCode.isEmpty))
            if store.emailCodeSent {
                Button(String(appStrings: .signInResendCode)) { store.send(.emailResendTap) }
                    .disabled(store.loginInFlight)
                Button(String(appStrings: .signInChangeEmail)) { store.send(.emailChangeTap) }
                    .disabled(store.loginInFlight)
            }
            Button {
                store.send(.signUpWithAppleButtonTap)
            } label: {
                HStack(spacing: 14) {
                    if store.appleLoginInFlight {
                        ProgressView()
                            .transition(.blurReplace)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color.themeText)
                            )
                    }
                    Image.iconApple
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18)
                    Text(String(appStrings: .signInApple))
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.themeText, foregroundColor: Color.themeBackground))
            .disabled(store.loginInFlight)
            Button {
                store.send(.signUpWithGoogleButtonTap)
            } label: {
                HStack(spacing: 14) {
                    if store.googleLoginInFlight {
                        ProgressView()
                            .transition(.blurReplace)
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: Color.themeText)
                            )
                    }
                    Image.iconGoogle
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                    Text(String(appStrings: .signInGoogle))
                        .foregroundStyle(Color.themeText)
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(
                LargeButtonStyle(
                    backgroundColor: Color.themeSurface
                )
            )
            .disabled(store.loginInFlight)
            .lightShadow()
        }
        .animation(.bouncy, value: store.googleLoginInFlight)
        .animation(.bouncy, value: store.appleLoginInFlight)
        
        .padding(.all, Theme.padding)
    }
}

#if DEBUG
private struct E2EAuthenticationDebugView: View {
    let store: StoreOf<SignUp>

    var body: some View {
        NavigationStack {
            List {
                Section(String(appStrings: .debugE2eLogin)) {
                    Button(String(appStrings: .debugInjectedLogin)) {
                        store.send(.e2eLoginWithInjectedTokenTap)
                    }
                    .accessibilityIdentifier("e2e_login_with_injected_token")
                }
                if let status = store.e2eAuthenticationStatus {
                    Section(String(appStrings: .debugStatus)) {
                        Text(status)
                            .captionTextStyle()
                    }
                }
            }
            .navigationTitle(String(appStrings: .debugAuthentication))
        }
    }
}
#endif

#Preview {
    SignUpView(
        store: .init(
            initialState: .init(),
            reducer: {
                SignUp()
            }
        )
    )
}
