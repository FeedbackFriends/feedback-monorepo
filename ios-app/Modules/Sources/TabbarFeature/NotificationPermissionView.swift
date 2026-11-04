import Localization
import SwiftUI
import DesignSystem

struct NotificationPermissionView: View {
        
    let requestAuthorizationButtonTap: () -> Void
    let dismissButtonTap: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                LottieView(lottieFile: .messagePermission)
                    .frame(width: 300, height: 200)
                    Text(String(appStrings: .notificationsPermissionMessage))
                        .padding(.top, 30)
                        .bodyTextStyle()
                        .padding(.horizontal, 60)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.themeText)
                Spacer()
                givePermissionButton(String(appStrings: .notificationsAllow)) {
                    requestAuthorizationButtonTap()
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar { toolbarContent }
            .navigationTitle(String(appStrings: .notificationsTitle))
            .navigationBarTitleDisplayMode(.large)
            .background(Color.themeBackground.ignoresSafeArea())
        }
        .presentationBackground(Color.themeBackground)
    }
}

private extension NotificationPermissionView {
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(appStrings: .commonNotNow)) {
                    dismissButtonTap()
                }
                .buttonStyle(SecondaryTextButtonStyle())
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    func givePermissionButton(_ buttonText: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image.checkmarkCircleFill
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.themeSuccess)
                Text(buttonText)
                    .rowTitleTextStyle()
                    .foregroundColor(.themeText)
                Spacer()
            }
        }
        .buttonStyle(LargeBoxButtonStyle())
    }
}

#Preview {
    NotificationPermissionView(
        requestAuthorizationButtonTap: {},
        dismissButtonTap: {}
    )
}

#Preview {
    @Previewable @State var showSheet: Bool = false
    Button("Vis vindue") {
        showSheet = true
    }
    .sheet(isPresented: $showSheet) {
        NotificationPermissionView(
            requestAuthorizationButtonTap: {},
            dismissButtonTap: {}
        )
        .presentationDetents([.height(600)])
    }
}
