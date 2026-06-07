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
                    detail: event,
                    agenda: store.activity?.agenda
                )
            } else {
                EmptyStateView(
                    title: "Sessionen er ikke tilgængelig",
                    message: "Denne session kan ikke længere åbnes."
                )
                .padding(.horizontal, Theme.padding)
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(Color.themeText)
        .background(Color.themeBackground)
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
                    .accessibilityLabel("Inviter")
                    .accessibilityIdentifier("session_detail_invite_button")

                    Button {
                        store.send(.editButtonTapped)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(store.event == nil)
                    .accessibilityLabel("Rediger session")
                    .accessibilityIdentifier("session_detail_edit_button")

                    Button(role: .destructive) {
                        store.send(.deleteEventButtonTapped)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(PrimaryTextButtonStyle())
                    .disabled(store.event == nil)
                    .accessibilityLabel("Slet session")
                    .accessibilityIdentifier("session_detail_delete_button")
                }
            }
        }
        .sheet(isPresented: $store.showDeleteConfirmation) {
            DeleteConfirmationViewSheet(
                title: "Slet session",
                message: "Slet denne session og dens feedback?",
                actionButton: {
                    Button("Slet") {
                        store.send(.deleteEventConfirmButtonTapped)
                    }
                    .buttonStyle(LargeBoxButtonStyle(color: Color.themeVerySad))
                    .isLoading(store.deleteEventInFlight)
                }
            )
            .presentationDetents([.height(340)])
        }
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
                    title: "Invitation ikke tilgængelig",
                    message: "Invitationer er ikke tilgængelige for denne session lige nu."
                )
                .padding(.horizontal, Theme.padding)
                .presentationDetents([.height(350)])
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.manageEvent,
                action: \.destination.manageEvent
            )
        ) { manageEventStore in
            NavigationStack {
                ManageEventView(store: manageEventStore)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .navigationTitle(store.navigationTitle)
        .navigationSubtitle(store.navigationSubTitle)
        .animation(.default, value: store.event)
    }
}
