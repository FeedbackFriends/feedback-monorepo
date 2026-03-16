@testable import Domain
import Foundation
import Testing

@MainActor
class DeeplinkParserTests {
    
    @Test
    func `Deeplink correctly parses FEEDBACK_RECEIVED notification payload`() {
        let uuid = UUID()
        let userInfo: [AnyHashable: Any] = [
            "type": "FEEDBACK_RECEIVED",
            "eventId": uuid.uuidString
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        switch deeplink {
        case .managerEvent(let id):
            #expect(id == uuid)
        default:
            fatalError("Expected .managerEvent")
        }
    }
    
    @Test
    func `Deeplink returns nil when notification payload is missing type`() {
        let userInfo: [AnyHashable: Any] = [
            "eventId": UUID().uuidString
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func `Deeplink returns nil when event ID is invalid`() {
        let userInfo: [AnyHashable: Any] = [
            "type": "FEEDBACK_RECEIVED",
            "eventId": "not-a-uuid"
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func `Deeplink returns nil when notification payload has unexpected type`() {
        let userInfo: [AnyHashable: Any] = [
            "type": "UNKNOWN_TYPE",
            "eventId": UUID().uuidString
        ]
        let deeplink = Deeplink(notificationUserInfo: userInfo)
        #expect(deeplink == nil)
    }
    
    @Test
    func `Deeplink correctly parses join event URL`() {
        let url = URL(string: "letsgrow://invite?pin_code=1234")!
        guard let deeplink = Deeplink(url: url) else {
            fatalError()
        }
        switch deeplink {
        case .joinEvent(let pinCode):
            #expect(pinCode == .init(value: "1234"))
        case .managerEvent:
            fatalError()
        }
    }
    
    @Test
    func `Deeplink returns nil for empty URL`() {
        let url = URL(string: "letsgrow://")!
        let deeplink = Deeplink(url: url)
        #expect(deeplink == nil)
    }
    
    @Test
    func `Deeplink returns nil for unsupported URL scheme`() {
        let url = URL(string: "wtf://")!
        let deeplink = Deeplink(url: url)
        #expect(deeplink == nil)
    }
}
