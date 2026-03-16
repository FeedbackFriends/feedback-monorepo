import SwiftUI
import DesignSystem

struct NotificationPermissionView: View {

    let enablePushNotificationsButtonTap: () -> Void
    let enableEmailsButtonTap: () -> Void
    let isLoading: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                LottieView(lottieFile: .messagePermission)
                    .frame(width: 300, height: 200)
                    .padding(.top, 8)

                VStack(spacing: 8) {
                    Text("Choose your update channel")
                        .font(.montserratSemiBold, 20)
                        .foregroundStyle(Color.themeText)

                    Text("Email updates are on by default. Add push notifications for instant reminders.")
                        .font(.montserratRegular, 14)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.themeTextSecondary)
                }
                .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    givePermissionButton(
                        title: "Enable push notifications",
                        subtitle: "Instant reminders when new sessions and feedback activity happen.",
                        systemImageName: "bell.badge.fill",
                        badgeText: "Recommended",
                        badgeColor: Color.themePrimaryAction
                    ) {
                        enablePushNotificationsButtonTap()
                    }
                    .isLoading(isLoading)
                    .disabled(isLoading)

                    givePermissionButton(
                        title: "Continue with emails only",
                        subtitle: "Email updates are already enabled by default.",
                        systemImageName: "envelope.fill",
                        badgeText: "Default on",
                        badgeColor: Color.themeSuccess
                    ) {
                        enableEmailsButtonTap()
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 0)

                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.themePrimaryAction))
                        Text("Applying your preference...")
                            .font(.montserratRegular, 12)
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                    .padding(.bottom, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Never miss feedback")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private extension NotificationPermissionView {
    func givePermissionButton(
        title: String,
        subtitle: String,
        systemImageName: String,
        badgeText: String?,
        badgeColor: Color,
        onTap: @escaping () -> Void
    ) -> some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.themePrimaryAction.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: systemImageName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.themePrimaryAction)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.montserratBold, 14)
                            .foregroundStyle(Color.themeText)
                        if let badgeText {
                            Text(badgeText)
                                .font(.montserratSemiBold, 10)
                                .foregroundStyle(badgeColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(badgeColor.opacity(0.14), in: Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.montserratRegular, 12)
                        .foregroundStyle(Color.themeTextSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image.chevronRight
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(Color.themeTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NotificationPermissionView(
        enablePushNotificationsButtonTap: {},
        enableEmailsButtonTap: {},
        isLoading: false
    )
}

#Preview {
    @Previewable @State var showSheet: Bool = false
    Button("Show sheet") {
        showSheet = true
    }
    .sheet(isPresented: $showSheet) {
        NotificationPermissionView(
            enablePushNotificationsButtonTap: {},
            enableEmailsButtonTap: {},
            isLoading: false
        )
        .presentationDetents([.height(600)])
    }
}
