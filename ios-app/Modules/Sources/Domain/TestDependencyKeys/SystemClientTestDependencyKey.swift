import ComposableArchitecture
import Foundation
import UIKit

extension SystemClient: TestDependencyKey {
    public static let testValue = SystemClient()
    public static let previewValue = SystemClient()
}
