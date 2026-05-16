import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct JoinEventView: View {
    
    @FocusState var pinCodeTextfieldFocused: Bool
    @Bindable var store: StoreOf<JoinEvent>
    
    public init(store: StoreOf<JoinEvent>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                
                Text("Join session")
                    .font(.montserratBold, 28)
                    .padding(.top, 20)
                Text("PIN Code")
                    .padding(.top, 20)
                    .font(.montserratBold, 18)
                    .foregroundStyle(Color.themeText)
                TextField("", text: $store.pinCodeInput.value)
                    .font(.montserratBold, 16)
                    .padding()
                    .foregroundColor(Color.themeText)
                    .background(Color.themeText.opacity(0.15).gradient)
                    .clipShape(Capsule())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .submitLabel(.next)
                    .focused($pinCodeTextfieldFocused)
                    .padding(.top, 5)
                    .pinCodeInputValidation(pinCodeInput: $store.pinCodeInput)
                Button("Join") {
                    store.send(.joinButtonTap)
                }
                .buttonStyle(LargeButtonStyle())
                .isLoading(store.joinRequestInFlight)
                .padding(.bottom, 50)
                .disabled(store.disableJoinButton)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .synchronize($store.pinCodeTextfieldFocused, $pinCodeTextfieldFocused)
            .onAppear { store.send(.onAppear) }
            .padding(.all, Theme.padding)
            .multilineTextAlignment(.center)
            .frame(maxWidth: Constants.maxWidthForLargeDevices, maxHeight: .infinity, alignment: .center)
            .foregroundStyle(Color.themeText.gradient)
            .background {
                /// this makes the keyboard to appear with a single animation
                FirstResponderFieldView()
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .background(Color.themeSurface.ignoresSafeArea())
            }
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .successOverlay(
                message: "Session joined",
                show: $store.showSuccessOverlay
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        store.send(.closeButtonTap)
                    }
                }
            }
        }
    }
}

#Preview {
    JoinEventView(
        store: .init(
            initialState: .init(),
            reducer: {
                JoinEvent()
            }
        )
    )
}

#Preview {
    @Previewable @State var showDeleteConfirmation: Bool = false
    Button("Join") {
        showDeleteConfirmation = true
    }
    .sheet(isPresented: $showDeleteConfirmation) {
        JoinEventView(
            store: .init(
                initialState: .init(),
                reducer: {
                    JoinEvent()
                }
            )
        )
        .presentationDetents([.medium])
    }
}
