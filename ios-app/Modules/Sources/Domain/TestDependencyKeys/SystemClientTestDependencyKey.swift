import ComposableArchitecture

extension SystemClient: TestDependencyKey {
    public static let testValue = SystemClient()
    public static let previewValue = SystemClient()
}
