import SwiftUI

public extension Binding where Value == String? {
    
    func asNonOptional(defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? defaultValue },
            set: { newValue in self.wrappedValue = newValue.isEmpty ? nil : newValue }
        )
    }
}
