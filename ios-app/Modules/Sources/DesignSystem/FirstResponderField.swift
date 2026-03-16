import SwiftUI
import UIKit

public class FirstResponderField: UITextField {
    public init(keyboardType: UIKeyboardType = .numberPad) {
        super.init(frame: .zero)
        self.keyboardType = keyboardType
        becomeFirstResponder()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct FirstResponderFieldView: UIViewRepresentable {
    public init() {}
    public func makeUIView(context: Context) -> FirstResponderField {
        return FirstResponderField()
    }
    
    public func updateUIView(_ uiView: FirstResponderField, context: Context) {}
}
