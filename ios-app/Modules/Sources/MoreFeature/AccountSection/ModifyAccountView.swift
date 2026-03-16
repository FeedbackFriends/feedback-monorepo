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
                    TextField("Name", text: $store.nameInput)
                } header: {
                    Text("Name")
                        .sectionHeaderStyle()
                }
                Section {
                    TextField("Email", text: $store.emailInput)
                } header: {
                    Text("Email")
                        .sectionHeaderStyle()
                } footer: {
                    Text("Use the same email as your calendar account (Google, Outlook, etc.).")
                }
                Section {
                    TextField("Phone number", text: $store.phoneNumberInput)
                } header: {
                    Text("Phone number")
                        .sectionHeaderStyle()
                }
            }
            .font(.montserratRegular, 12)
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .scrollContentBackground(.hidden)
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle("Edit profile")
            .toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button("Save") {
						store.send(.saveButtonTap)
					}
					.buttonStyle(PrimaryTextButtonStyle())
					.isLoading(store.isLoading)
				}
				.sharedBackgroundVisibility(.hidden)
            }
        }
    }
}
