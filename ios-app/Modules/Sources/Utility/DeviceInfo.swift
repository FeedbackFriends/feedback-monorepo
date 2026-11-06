import Localization
import Foundation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public struct DeviceInfo {
    /// Device properties
    let deviceName: String
    let deviceModel: String
    let systemName: String
    let systemVersion: String
    let identifierForVendor: String
    
    /// App properties
    let appName: String
    let appVersion: String
    let appBuild: String
    let internalBundleIdentifier: String
    
    public init() {
        #if canImport(UIKit)
        let device = UIDevice.current
        self.deviceName = device.name
        self.deviceModel = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.identifierForVendor = device.identifierForVendor?.uuidString ?? "Unknown"
        #else
        let processInfo = ProcessInfo.processInfo
        self.deviceName = processInfo.hostName
        self.deviceModel = "Mac"
        self.systemName = "macOS"
        self.systemVersion = processInfo.operatingSystemVersionString
        self.identifierForVendor = Bundle.main.bundleIdentifier ?? "Unknown"
        #endif
        
        let bundle = Bundle.main
        self.appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? String(appStrings: .commonUnknown)
        self.appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String(appStrings: .commonUnknown)
        self.appBuild = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? String(appStrings: .commonUnknown)
        self.internalBundleIdentifier = bundle.bundleIdentifier ?? "Unknown"
    }
    
    public func deviceID() -> String {
        self.identifierForVendor
    }
    
    public func platform() -> String {
        "\(self.systemName) \(self.systemVersion) - \(self.deviceName) \(self.deviceModel)"
    }
    
    public func version() -> String {
        self.appVersion
    }
    
    public func build() -> String {
        self.appBuild
    }
    
    public func bundleIdentifier() -> String {
        self.internalBundleIdentifier
    }
    
    public func summary() -> String {
        String(appStrings: .supportDeviceDetails(deviceName, deviceModel, systemName, systemVersion, identifierForVendor)) + "\n\n" + String(appStrings: .supportAppDetails(appName, appVersion, appBuild, internalBundleIdentifier))
    }
}
