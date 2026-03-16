import Foundation

/// A thin wrapper around Bundle.main to read Info.plist keys safely.
struct InfoPlistReader {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    /// Read a String value for a given key
    func string(for key: String) -> String? {
        let output = bundle.object(forInfoDictionaryKey: key) as? String
        if output == "undefined" {
            print("⚠️ The secret key \(key) was not found. Please set it in App/Config/secrets.xcconfig or run the Feedback Mock scheme instead.")
        }
        return output
    }
    
    /// Read a URL value 
    func url(for hostKey: String, scheme schemeKey: String) -> URL? {
        guard let host = string(for: hostKey) else { return nil }
        guard let scheme = string(for: schemeKey) else { return nil }
        return URL(string: "\(scheme)://\(host)")
    }
    
    /// Read a RawRepresentable value (like an enum backed by String)
    func value<T: RawRepresentable>(for key: String) -> T? where T.RawValue == String {
        guard let string = string(for: key) else { return nil }
        return T(rawValue: string)
    }
    
    /// Read any value casted to a type
    func value<T>(for key: String) -> T? {
        bundle.object(forInfoDictionaryKey: key) as? T
    }
}
