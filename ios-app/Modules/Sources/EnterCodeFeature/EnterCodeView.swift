import Domain
import DesignSystem
import SwiftUI
import ComposableArchitecture

public struct EnterCodeView: View {
    
    @FocusState var enterCodeTextfieldFocused: Bool
    @Bindable var store: StoreOf<EnterCode>
    
    public init(store: StoreOf<EnterCode>) {
        self.store = store
    }
    
    public var body: some View {
        content
            .onTapGesture { store.send(.backgroundTap) }
            .background(Color.themeBackground.ignoresSafeArea())
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

private extension EnterCodeView {
    var content: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center) {
                    Spacer()
                    LetsGrowFeedbackLogoView()
                    
                    Spacer()
                    Text("Enter PIN Code")
                        .foregroundStyle(Color.themeTextSecondary)
                        .titleTextStyle()
                    TextField("", text: $store.pinCodeInput.value)
                        .rowTitleTextStyle()
                        .padding()
                        .background(Color.themeSurface)
                        .clipShape(Capsule(style: .continuous))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .submitLabel(.go)
                        .focused($enterCodeTextfieldFocused)
                        .sensoryFeedback(.selection, trigger: enterCodeTextfieldFocused) { _, new in
                            new == true
                        }
                        .pinCodeInputValidation(pinCodeInput: $store.pinCodeInput)
                        .frame(maxWidth: Constants.maxWidthForLargeDevices)
                    Button("Start feedback") {
                        store.send(.startFeedbackButtonTap)
                    }
                    .disabled(store.disableStartFeedbackButton)
                    .isLoading(store.startFeedbackPincodeInFlight)
                    .buttonStyle(LargeButtonStyle())
                    .padding(.top, 12)
                    Spacer()
                    Image.letsGrowIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 46)
                    Spacer()
                }
                .synchronize($store.enterCodeTextfieldFocused, $enterCodeTextfieldFocused)
                .padding(.all, Theme.padding)
                .foregroundStyle(Color.themeText)
                .frame(minHeight: proxy.size.height)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    EnterCodeView(
        store: .init(
            initialState: .init(),
            reducer: {
                EnterCode()
            }
        )
    )
}
