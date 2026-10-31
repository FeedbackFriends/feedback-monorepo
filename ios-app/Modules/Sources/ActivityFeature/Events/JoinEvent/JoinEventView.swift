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
                
                Text("Svar på feedback")
                    .titleTextStyle()
                Text("PIN-kode")
                    .padding(.top, 4)
                    .titleTextStyle()
                    .foregroundStyle(Color.themeText)
                PinCodeTextFieldView(
                    input: $store.pinCodeInput,
                    isFocused: $pinCodeTextfieldFocused,
                    submitLabel: .next,
                    background: Color.themeText.opacity(0.15).gradient
                )
                .padding(.top, 5)
                Button("Fortsæt") {
                    store.send(.joinButtonTap)
                }
                .buttonStyle(LargeButtonStyle())
                .isLoading(store.joinRequestInFlight)
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
            }
            .background(Color.themeSurface.ignoresSafeArea())
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView {
                        store.send(.closeButtonTap)
                    }
                }
            }
        }
        .successMessage("Session fundet", isPresented: store.isSuccessMessagePresented)
        .presentationBackground(Color.themeSurface)
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
    Button("Fortsæt") {
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
