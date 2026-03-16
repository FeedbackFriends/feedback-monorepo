import ComposableArchitecture
import SwiftUI
import FeedbackFlowFeature
import EventsFeature

@main
struct FeedbackFlowApp: App {
    var body: some Scene {
        WindowGroup {
            FeedbackFlowCoordinatorView(
                store: StoreOf<FeedbackFlowCoordinator>(
                    initialState: FeedbackFlowCoordinator.State.initialState(feedbackSession: .mock),
                    reducer: {
                        FeedbackFlowCoordinator()._printChanges()
                    },
                    withDependencies: {
                        $0.apiClient = .mock
                    }
                ),
                principalToolbarItem: {
                    Text("Hello title")
                        .font(.montserratBold, 12)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(8)
                }
            )
        }
    }
}


