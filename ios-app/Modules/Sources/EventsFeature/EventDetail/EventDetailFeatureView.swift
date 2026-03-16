import Domain
import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct EventDetailFeatureView: View {
    
    @Bindable var store: StoreOf<EventDetailFeature>
    
    public init(store: StoreOf<EventDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        
        let confirmationStore = $store.scope(
            state: \.destination?.confirmationDialog,
            action: \.destination.confirmationDialog
        )
        
        let inviteStore = $store.scope(
            state: \.destination?.invite,
            action: \.destination.invite
        )
                
        let editQuestionsStore = $store.scope(
            state: \.destination?.editQuestions,
            action: \.destination.editQuestions
        )
        
        let deleteConfirmationStore = $store.scope(
            state: \.destination?.deleteConfirmation,
            action: \.destination.deleteConfirmation
        )
        
        DetailSectionView(
            event: store.event
        )
        .overlay(alignment: .bottom) {
            aiInsightsFloatingButton
                .padding(.horizontal, Theme.padding)
                .padding(.bottom, 16)
        }
        .sheet(
            item: inviteStore
        ) { state in
            state.withState { _ in
                return InviteView(
                    inviteLink: store.inviteUrl,
                    shareText: store.shareText
                )
                .presentationDetents([.height(350)])
            }
        }
        .refreshable {
            await store.send(.refresh).finish()
        }
        .foregroundColor(Color.themeText)
        .frame(maxWidth: .infinity)
        .task { await store.send(.onTask).finish() }
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("More", systemImage: "ellipsis") {
					store.send(.moreButtonTapped)
				}
				.tint(Color.themeText)
				.confirmationDialog(confirmationStore)
			}
		}
        .navigationTitle(store.navigationTitle)
        .navigationSubtitle(store.navigationSubTitle)
        .sheet(item: editQuestionsStore) { store in
            NavigationStack {
                EditQuestionsView(store: store)
            }
        }
        .sheet(item: deleteConfirmationStore) { store in
            DeleteConfirmationView(store: store)
                .presentationDetents([.height(300)])
        }
        .animation(.default, value: store.event)
    }
    
    var aiInsightsFloatingButton: some View {
        Button {
            // Intentionally disabled until the feature is released.
        } label: {
            Text("AI insights")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(LargeButtonStyle(backgroundColor: Color.themeBlue))
        .overlay(alignment: .topTrailing) {
            Text("Coming soon")
                .font(.montserratSemiBold, 10)
                .foregroundStyle(Color.themeOnPrimaryAction)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.themeVerySad)
                .clipShape(Capsule())
                .offset(x: -8, y: -12)
        }
    }
}
