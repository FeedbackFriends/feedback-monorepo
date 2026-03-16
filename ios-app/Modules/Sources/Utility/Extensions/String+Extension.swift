public extension String {
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
}

public extension String {
    /// Returns a new string with the first character in lowercase.
    func lowercasingFirst() -> String {
        guard let first = self.first else { return self }
        return first.lowercased() + self.dropFirst()
    }
    /// Returns a new string with the first character in uppercase
    func uppercasingFirst() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}
