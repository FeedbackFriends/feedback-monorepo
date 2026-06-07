import Foundation
import SwiftUI
import ComposableArchitecture
import DesignSystem
import Domain

public struct SignUpView: View {
    
    @Bindable var store: StoreOf<SignUp>
    
    public init(store: StoreOf<SignUp>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.large)
            .background(Color.themeBackground)
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
            Text("Forbedr aktiviteter")
                .largeTitleTextStyle()
                .foregroundStyle(Color.themeText.gradient)
            Text("Log ind som mødeejer, eller svar hurtigt med en PIN-kode uden at oprette en konto.")
                .bodyTextStyle()
                .foregroundColor(.themeText)
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
                    Text("Fortsæt med Apple")
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.themeText, foregroundColor: Color.themeBackground))
            .disabled(store.googleLoginInFlight || store.appleLoginInFlight || store.anonymousLoginInFlight)
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
                    Text("Fortsæt med Google")
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
            .disabled(store.googleLoginInFlight || store.appleLoginInFlight || store.anonymousLoginInFlight)
            .lightShadow()
            Button {
                store.send(.skipButtonTap)
            } label: {
                HStack(spacing: 8) {
                    if store.anonymousLoginInFlight {
                        ProgressView()
                    }
                    Text("Svar med PIN")
                }
            }
            .buttonStyle(PrimaryTextButtonStyle())
            .disabled(store.googleLoginInFlight || store.appleLoginInFlight || store.anonymousLoginInFlight)
            .padding(.bottom, 16)
        }
        .animation(.bouncy, value: store.googleLoginInFlight)
        .animation(.bouncy, value: store.appleLoginInFlight)
        .animation(.bouncy, value: store.anonymousLoginInFlight)
        .padding(.all, Theme.padding)
    }
}

#if DEBUG
private struct E2EAuthenticationDebugView: View {
    let store: StoreOf<SignUp>

    var body: some View {
        NavigationStack {
            List {
                Section("E2E login") {
                    Button("Login with injected E2E token") {
                        store.send(.e2eLoginWithInjectedTokenTap)
                    }
                    .accessibilityIdentifier("e2e_login_with_injected_token")
                }
                if let status = store.e2eAuthenticationStatus {
                    Section("Status") {
                        Text(status)
                            .captionTextStyle()
                    }
                }
            }
            .navigationTitle("E2E authentication")
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
