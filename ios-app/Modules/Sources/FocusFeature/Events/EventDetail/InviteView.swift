import SwiftUI
import DesignSystem
#if canImport(UIKit)
import UIKit
#endif

struct InviteView: View {
    let inviteLink: String
    let shareText: String
    @State private var shareSheet: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    infoSection
                    linkSection
                    shareButton
                }
                .padding(.horizontal, 18)
                .navigationTitle("Inviter")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CloseButtonView { dismiss() }
                    }
                }
                .foregroundStyle(Color.themeText)
            }
            .sheet(item: $shareSheet, id: \.self) { shareContent in
                ShareSheet(activityItems: [shareContent])
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Del linket med de deltagere, du gerne vil have feedback fra.")
                .bodyTextStyle()
        }
    }
    
    private var linkSection: some View {
        VStack(alignment: .leading) {
            Text(inviteLink)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.themeSurface)
                .foregroundStyle(Color.themeText)
                .cornerRadius(14)
                .bodyTextStyle()
                .overlay(copyButton, alignment: .trailing)
        }
    }
    
    private var copyButton: some View {
		Button {
			shareSheet = inviteLink
		} label: {
			HStack {
                Image.copyActionIcon
			}
			.padding(.trailing, 12)
		}
        .accessibilityIdentifier("invite_copy_link")
        .buttonStyle(SecondaryTextButtonStyle())
        .frame(maxHeight: .infinity)
    }
    
    private var shareButton: some View {
		Button {
			shareSheet = shareText
		} label: {
			HStack {
                Image.shareActionIcon
					.fontWeight(.semibold)
				Text("Inviter")
			}
		}
        .buttonStyle(LargeButtonStyle())
        .padding(.vertical, 8)
    }
}

/// ShareSheet is needed in InviteView since there is a problem with ShareLink when presenting from a sheet
#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
#else
struct ShareSheet: View {
    let activityItems: [Any]

    var body: some View {
        EmptyView()
    }
}
#endif

#Preview {
    InviteView(
        inviteLink: "https://example.com",
        shareText: "ShareText"
    )
}
