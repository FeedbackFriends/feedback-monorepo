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
            .sheet(
                item: $store.scope(
                    state: \.destination?.selectUserType,
                    action: \.destination.selectUserType
                )
            ) { store in
                SelectUserTypeView(store: store)
                    .interactiveDismissDisabled()
                    .presentationDetents([.height(240)])
            }
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
            Text("Sign up")
                .font(.montserratBold, 28)
                .foregroundStyle(Color.themeText.gradient)
            Text("Signup to get started on your feedback jurney.")
                .font(.montserratRegular, 14)
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
                    Text("Continue with Apple")
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: Color.black))
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
                    Text("Continue with Google")
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
                    Text("Skip for now")
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
    @State private var loginId: String = ""
    @State private var selectedPresetLoginId: String = "mock-firebase-only-empty"

    private let presetLoginIds: [String] = [
        "mock-firebase-only-empty",
        "mock-manager-empty",
        "mock-manager-with-data",
        "mock-participant-empty",
        "mock-participant-with-data"
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Seed users") {
                    Button("Seed participant with data") {
                        store.send(.e2eSeedParticipantWithDataTap)
                    }
                    Button("Seed participant empty") {
                        store.send(.e2eSeedParticipantEmptyTap)
                    }
                    Button("Seed manager with data") {
                        store.send(.e2eSeedManagerWithDataTap)
                    }
                    Button("Seed manager empty") {
                        store.send(.e2eSeedManagerEmptyTap)
                    }
                    .accessibilityIdentifier("e2e_seed_manager_empty")
                    Button("Seed empty account") {
                        store.send(.e2eSeedEmptyAccountTap)
                    }
                }
                Section("E2E login") {
                    TextField("E2E login id", text: $loginId)
                        .textFieldStyle(.roundedBorder)
                    Button("E2E login endpoint (/admin/login) with id") {
                        store.send(.e2eLoginWithIdTap(loginId))
                    }
                    Picker("Preset login id", selection: $selectedPresetLoginId) {
                        ForEach(presetLoginIds, id: \.self) { presetId in
                            Text(presetId).tag(presetId)
                        }
                    }
                    Button("E2E login endpoint (/admin/login) with preset") {
                        store.send(.e2eLoginWithPresetTap(selectedPresetLoginId))
                    }
                }
                if let status = store.e2eAuthenticationStatus {
                    Section("Status") {
                        Text(status)
                            .font(.caption)
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
