import Localization
import ComposableArchitecture
import SwiftUI
import Domain
import DesignSystem

public struct ModifyAccountView: View {
    
    @Bindable var store: StoreOf<ModifyAccount>
    
    public init(store: StoreOf<ModifyAccount>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(appStrings: .profileName), text: $store.nameInput)
                        .textInputTextStyle()
                } header: {
                    SectionHeaderView(String(appStrings: .profileName), horizontalPadding: 0)
                }
                Section {
                    TextField(String(appStrings: .profileEmail), text: $store.emailInput)
                        .textInputTextStyle()
                } header: {
                    SectionHeaderView(String(appStrings: .profileEmail), horizontalPadding: 0)
                } footer: {
                    Text(String(appStrings: .profileCalendarEmailHelp))
                }
                Section {
                    TextField(String(appStrings: .profilePhone), text: $store.phoneNumberInput)
                        .textInputTextStyle()
                } header: {
                    SectionHeaderView(String(appStrings: .profilePhone), horizontalPadding: 0)
                }
            }
            .supportingTextStyle()
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .scrollContentBackground(.hidden)
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle(String(appStrings: .profileEdit))
            .toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button(String(appStrings: .commonSave)) {
						store.send(.saveButtonTap)
					}
					.buttonStyle(PrimaryTextButtonStyle())
					.isLoading(store.isLoading)
                    .disabled(store.isLoading)
				}
				.sharedBackgroundVisibility(.hidden)
            }
        }
    }
}
