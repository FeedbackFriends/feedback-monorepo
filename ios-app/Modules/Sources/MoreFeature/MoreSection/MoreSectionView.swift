import Foundation
import SwiftUI
import DesignSystem
import ComposableArchitecture
import Domain
import Utility

public struct MoreSectionView: View {
    
    @Bindable var store: StoreOf<MoreSection>
    
    public init(store: StoreOf<MoreSection>) {
        self.store = store
    }
    
    var appVersionFooterText: String {
        "\(DeviceInfo().version())(\(DeviceInfo().build()))"
    }
    
    public var body: some View {
        Group {
            contactSection
            if let appStoreReviewUrl = store.appStoreReviewUrl {
                shareSection(appStoreReviewUrl: appStoreReviewUrl)
            }
            generalSection
        }
        .onAppear { store.send(.onAppear) }
    }
    
    var generalSection: some View {
        Group {
            Section {
                Button {
                    store.send(.onNotificationsButtonTap)
                } label: {
                    listElementView(image: .moreSectionBell, label: "Notifikationer")
                }
                if let privacyPolicyUrl = store.privacyPolicyUrl {
                    Link(destination: privacyPolicyUrl) {
                        listElementView(image: .moreSectiondocPlaintext, label: "Privatlivspolitik")
                    }
                    .onOpenURL(prefersInApp: true)
                }
                Button {
                    store.send(.onSupportUsButtonTap)
                } label: {
                    HStack {
                        Image.heartFill
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.themePrimaryAction.gradient)
                        Text("Støt os")
                    }
                    .bodyTextStyle()
                    .foregroundColor(.themeText)
                }
                
            } header: {
                SectionHeaderView("Generelt", horizontalPadding: 0)
            } footer: {
                Text(appVersionFooterText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .captionTextStyle()
                    .padding(.vertical, 20)
            }
        }
        .foregroundColor(Color.themeText)
        .scrollContentBackground(.hidden)
    }
    
    var contactSection: some View {
        Section {
            Button {
                store.send(.onFeedbackButtonTap)
            } label: {
                listElementView(image: .moreSectionElipsisBubble, label: "Send feedback til os")
            }
            Button {
                store.send(.onReportBugButtonTap)
            } label: {
                listElementView(image: .moreSectionExlamaionmarkSquare, label: "Rapportér en fejl")
            }
        } header: {
            SectionHeaderView("Kontakt os", horizontalPadding: 0)
        }
    }
    
    func shareSection(appStoreReviewUrl: URL) -> some View {
        Section {
            ShareLink(item: appStoreReviewUrl) {
                VStack(spacing: 10) {
                    Text("Inviter flere mødeejere")
                        .titleTextStyle()
                        .foregroundStyle(Color.themeOnPrimaryAction)
                    Text("Gør aktiviteter lettere at forbedre")
                        .bodyTextStyle()
                        .foregroundStyle(Color.themeOnPrimaryAction)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeOnPrimaryAction)
            }
        }
        .listRowBackground(
            Rectangle()
                .foregroundStyle(Color.themePrimaryAction)
        )
    }
}

#Preview {
    NavigationStack {
        MoreSectionView(
            store: StoreOf<MoreSection>(
                initialState: MoreSection.State(),
                reducer: {
                    MoreSection()
                }
            )
        )
    }
}
