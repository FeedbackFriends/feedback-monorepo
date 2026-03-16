import Foundation
import UIKit

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
        let device = UIDevice.current
        self.deviceName = device.name
        self.deviceModel = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.identifierForVendor = device.identifierForVendor?.uuidString ?? "Unknown"
        
        let bundle = Bundle.main
        self.appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown"
        self.appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        self.appBuild = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
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
        """
        Device Info:
        Device Name: \(deviceName)
        Model: \(deviceModel)
        System: \(systemName) \(systemVersion)
        Vendor Identifier: \(identifierForVendor)
        
        App Info:
        App Name: \(appName)
        Version: \(appVersion)
        Build: \(appBuild)
        Bundle Identifier: \(internalBundleIdentifier)
        """
    }
}
