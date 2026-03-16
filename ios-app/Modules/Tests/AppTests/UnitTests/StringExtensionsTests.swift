import Testing
@testable import Utility

final class StringExtensionsTests {
    
    @Test
    func `NilIfEmpty returns nil for empty string`() {
        let emptyString = ""
        #expect(emptyString.nilIfEmpty == nil)
    }
    
    @Test
    func `NilIfEmpty returns original string when non-empty`() {
        let nonEmptyString = "Hello"
        #expect(nonEmptyString.nilIfEmpty == "Hello")
    }
    
    @Test
    func `Lowercasing first letter returns empty string when input is empty`() {
        let emptyString = ""
        #expect(emptyString.lowercasingFirst().isEmpty)
    }
    
    @Test
    func `Lowercasing first letter works correctly for non-empty string`() {
        let string = "Hello"
        #expect(string.lowercasingFirst() == "hello")
    }
    
    @Test
    func `Uppercasing first letter returns empty string when input is empty`() {
        let emptyString = ""
        #expect(emptyString.uppercasingFirst().isEmpty)
    }
    
    @Test
    func `Uppercasing first letter works correctly for non-empty string`() {
        let string = "helloHello"
        #expect(string.uppercasingFirst() == "HelloHello")
    }
}
