import SwiftUI
import DesignSystem
import UIKit

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
                .navigationTitle("Invite")
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
            Text("Share the link with people you would like feedback from 🤝")
                .font(.montserratRegular, 14)
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
                .font(.montserratMedium, 14)
                .overlay(copyButton, alignment: .trailing)
        }
    }
    
    private var copyButton: some View {
		Button {
			shareSheet = inviteLink
		} label: {
			HStack {
                Image.documentOnDocument
					.font(.system(size: 16, weight: .regular))
			}
			.padding(.trailing, 12)
		}
        .buttonStyle(SecondaryTextButtonStyle())
        .frame(maxHeight: .infinity)
    }
    
    private var shareButton: some View {
		Button {
			shareSheet = shareText
		} label: {
			HStack {
                Image.squareAndArrowUp
					.font(.system(size: 14, weight: .semibold))
				Text("Invite")
			}
		}
        .buttonStyle(LargeButtonStyle())
        .padding(.vertical, 8)
    }
}

/// ShareSheet is needed in InviteView since there is a problem with ShareLink when presenting from a sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

#Preview {
    InviteView(
        inviteLink: "https://example.com",
        shareText: "ShareText"
    )
}
