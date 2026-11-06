import Localization
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

public struct EventDetailFeatureView: View {
    @Bindable var store: StoreOf<EventDetailFeature>

    public init(store: StoreOf<EventDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let event = store.event {
                DetailSectionView(
                    detail: event
                )
            } else if store.deleteEventInFlight || store.wasDeleted {
                Color.themeBackground.ignoresSafeArea()
            } else {
                EmptyStateView(
                    title: String(appStrings: .sessionUnavailableTitle),
                    message: String(appStrings: .sessionUnavailableMessage)
                )
                .padding(.horizontal, Theme.padding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .successConfirmation(store.scope(state: \.confirmation, action: \.confirmation))
        .foregroundStyle(Color.themeText)
        .background(Color.themeBackground.ignoresSafeArea())
        .task { await store.send(.onTask).finish() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        store.send(.inviteButtonTapped)
                    } label: {
                        Image.squareAndArrowUp
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(store.event?.pinCode == nil)
                    .accessibilityLabel(String(appStrings: .commonInvite))
                    .accessibilityIdentifier("session_detail_invite_button")

                    Button {
                        store.send(.editButtonTapped)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(store.event == nil)
                    .accessibilityLabel(String(appStrings: .sessionEdit))
                    .accessibilityIdentifier("session_detail_edit_button")

                    Button(role: .destructive) {
                        store.send(.deleteEventButtonTapped)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(store.event == nil)
                    .accessibilityLabel(String(appStrings: .sessionDeleteTitle))
                    .accessibilityIdentifier("session_detail_delete_button")
                }
            }
        }
        .sheet(
            isPresented: $store.showDeleteConfirmation,
            onDismiss: { store.send(.deleteConfirmationDismissed) },
            content: {
                DeleteConfirmationViewSheet(
                    title: String(appStrings: .sessionDeleteTitle),
                    message: String(appStrings: .sessionDeleteMessage),
                    actionButton: {
                        Button(String(appStrings: .commonDelete)) {
                            store.send(.deleteEventConfirmButtonTapped)
                        }
                        .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                        .isLoading(store.deleteEventInFlight)
                    }
                )
                .presentationDetents([.height(340)])
            }
        )
        .sheet(
            item: $store.scope(
                state: \.destination?.invite,
                action: \.destination.invite
            )
        ) { _ in
            if let inviteUrl = store.inviteUrl, let shareText = store.shareText {
                InviteView(
                    inviteLink: inviteUrl,
                    shareText: shareText
                )
                .presentationDetents([.height(350)])
            } else {
                EmptyStateView(
                    title: String(appStrings: .sessionInviteUnavailableTitle),
                    message: String(appStrings: .sessionInviteUnavailableMessage)
                )
                .padding(.horizontal, Theme.padding)
                .presentationDetents([.height(350)])
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.manageEvent,
                action: \.destination.manageEvent
            ),
            onDismiss: { store.send(.confirmation(.transitionCompleted)) },
            content: { manageEventStore in
                NavigationStack {
                    ManageEventView(store: manageEventStore)
                }
            }
        )
        .alert($store.scope(state: \.alert, action: \.alert))
        .navigationTitle(store.navigationTitle)
        .navigationSubtitle(store.navigationSubTitle)
        .animation(.default, value: store.event)
    }
}
