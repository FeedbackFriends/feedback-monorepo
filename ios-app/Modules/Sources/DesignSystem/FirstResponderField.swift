import SwiftUI
#if canImport(UIKit)
import UIKit

public class FirstResponderField: UITextField {
    public init(keyboardType: UIKeyboardType = .numberPad, automaticallyFocus: Bool = true) {
        super.init(frame: .zero)
        self.keyboardType = keyboardType
        if automaticallyFocus { becomeFirstResponder() }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct FirstResponderFieldView: UIViewRepresentable {
    #if DEBUG
    @Environment(\.isScreenSnapshot) private var isScreenSnapshot
    #endif
    public init() {}
    public func makeUIView(context: Context) -> FirstResponderField {
        #if DEBUG
        return FirstResponderField(automaticallyFocus: !isScreenSnapshot)
        #else
        return FirstResponderField()
        #endif
    }

    public func updateUIView(_ uiView: FirstResponderField, context: Context) {}
}
#else
public struct FirstResponderFieldView: View {
    public init() {}

    public var body: some View {
        EmptyView()
    }
}
#endif
