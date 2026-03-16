import RootFeature
import ComposableArchitecture
import SwiftUI
import DesignSystem
import Logger
import Domain

@main
struct FeedbackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {}
    
    var body: some Scene {
        WindowGroup {
            RootFeatureView(store: appDelegate.intialStore)
                .onOpenURL { url in
                    guard let deeplink = Deeplink(url: url) else { return }
                    appDelegate.intialStore.send(.onUrlOpen(deeplink))
                }
                #if DEBUG
                .overlay(alignment: .trailing) {
                    DebugMenuView(apiClient: appDelegate.apiClient, notificationClient: appDelegate.notificationClient)
                }
                #endif
        }
    }
}
