import ComposableArchitecture
import DesignSystem
import SwiftUI

struct ActivityDetailSessionListView: View {
    let store: StoreOf<ActivityDetailSessionList>

    var body: some View {
        ScrollView {
            EventListView(
                sections: store.sections,
                eventTitle: store.eventTitle,
                onEventTap: { store.send(.eventTapped($0)) }
            )
            .padding()
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle(store.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
