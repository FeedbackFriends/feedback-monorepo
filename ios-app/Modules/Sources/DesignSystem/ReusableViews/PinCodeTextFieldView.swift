import Domain
import SwiftUI

public struct PinCodeTextFieldView<Background: ShapeStyle>: View {
    @Binding private var input: PinCodeInput
    @FocusState.Binding private var isFocused: Bool
    private let background: Background
    private let submitLabel: SubmitLabel

    public init(
        input: Binding<PinCodeInput>,
        isFocused: FocusState<Bool>.Binding,
        submitLabel: SubmitLabel = .go,
        background: Background
    ) {
        self._input = input
        self._isFocused = isFocused
        self.submitLabel = submitLabel
        self.background = background
    }

    public var body: some View {
        TextField("", text: $input.value)
            .accessibilityLabel("PIN-kode")
            .rowTitleTextStyle()
            .padding()
            .foregroundStyle(Color.themeText)
            .background(background, in: Capsule(style: .continuous))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .submitLabel(submitLabel)
            .focused($isFocused)
            .pinCodeInputValidation(pinCodeInput: $input)
    }
}

public extension PinCodeTextFieldView where Background == Color {
    init(
        input: Binding<PinCodeInput>,
        isFocused: FocusState<Bool>.Binding,
        submitLabel: SubmitLabel = .go
    ) {
        self.init(input: input, isFocused: isFocused, submitLabel: submitLabel, background: .themeSurface)
    }
}
