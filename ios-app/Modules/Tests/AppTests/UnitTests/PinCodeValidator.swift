@testable import Domain
import Foundation
import Testing

@MainActor
struct PinCodeValidatorTests {
    
    @Test func `Pin code input validation behaves correctly for various cases`() async throws {
        
        let validPin = PinCodeInput(value: "1234")
        #expect(validPin.isValidInput() == true)
        #expect(validPin.pinCode() == .init(value: "1234"))
        
        let shortPin = PinCodeInput(value: "123")
        #expect(shortPin.isValidInput() == true)
        #expect(shortPin.pinCode() == nil)
        
        let longPin = PinCodeInput(value: "12345")
        #expect(longPin.isValidInput() == false)
        #expect(longPin.pinCode() == nil)
        
        let nonNumericPin = PinCodeInput(value: "123a")
        #expect(nonNumericPin.isValidInput() == false)
        #expect(nonNumericPin.pinCode() == nil)
        
        let emptyPin = PinCodeInput(value: "")
        #expect(emptyPin.isValidInput() == true)
        #expect(emptyPin.pinCode() == nil)
        
        let pinWithSpaces = PinCodeInput(value: "12 34")
        #expect(pinWithSpaces.isValidInput() == false)
        #expect(pinWithSpaces.pinCode() == nil)
        
        let pinWithSpecialCharacters = PinCodeInput(value: "12$#")
        #expect(pinWithSpecialCharacters.isValidInput() == false)
        #expect(pinWithSpecialCharacters.pinCode() == nil)
    }
    
}
