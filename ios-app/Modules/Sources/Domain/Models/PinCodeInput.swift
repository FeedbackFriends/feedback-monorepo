public struct PinCodeInput: Equatable, Sendable {
    
    private let pinLength = 4
    
    public var value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public static func initial() -> Self {
        return .init(value: "")
    }
    
    public func isValidInput() -> Bool {
        return self.value.count <= pinLength && self.value.allSatisfy { $0.isNumber }
    }
    public func pinCode() -> PinCode? {
        return self.value.count == pinLength && self.value.allSatisfy { $0.isNumber } ? PinCode(value: self.value) : nil
    }
}
