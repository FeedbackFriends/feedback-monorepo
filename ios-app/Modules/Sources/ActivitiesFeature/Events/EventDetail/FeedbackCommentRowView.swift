import Domain
import SwiftUI
import DesignSystem

struct FeedbackCommentRowView: View {
    
    let feedback: Feedback
    
    var body: some View {
        switch feedback.type {
        case .emoji(emoji: let emoji, comment: let optionalComment):
            emojiRow(emoji: emoji, optionalComment: optionalComment)
        case .comment(comment: let comment):
            commentRow(comment: comment)
        case .zeroToTen(zeroToTen: let zeroToTen, comment: let optionalComment):
            zeroToTenRow(zeroToTen: zeroToTen, optionalComment: optionalComment)
        case .opinion(opinion: let opinion, comment: let optionalComment):
            opinionRow(opinion: opinion, optionalComment: optionalComment)
        case .thumpsUpThumpsDown(thumbsUpThumpsDown: let thumbsUpThumpsDown, comment: let optionalComment):
            thumpsRow(thumps: thumbsUpThumpsDown, optionalComment: optionalComment)
        }
    }
    
    @ViewBuilder
    func emojiRow(emoji: Emoji, optionalComment: String?) -> some View {
        if let comment = optionalComment {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    emoji.icon
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment)
                            .font(.montserratMedium, 12)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                feedbackInfo(feedback: feedback)
            }
            .foregroundStyle(Color.themeTextSecondary)
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    func commentRow(comment: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(comment)
                    .font(.montserratMedium, 12)
                    .fixedSize(horizontal: false, vertical: true)
                feedbackInfo(feedback: feedback)
            }
        }
        .foregroundStyle(Color.themeTextSecondary)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    func zeroToTenRow(zeroToTen: Int, optionalComment: String?) -> some View {
        if let comment = optionalComment {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text("\(zeroToTen)")
                        .font(.montserratSemiBold, 13)
                        .padding(2)
                        .padding(.horizontal, 4)
                        .foregroundStyle(Color.themeOnPrimaryAction)
                        .background(zeroToTen.ratingColor.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    Text(comment)
                        .font(.montserratMedium, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                feedbackInfo(feedback: feedback)
            }
            .foregroundStyle(Color.themeTextSecondary)
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    func opinionRow(opinion: Opinion, optionalComment: String?) -> some View {
        if let comment = optionalComment {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(opinion.color.gradient)
                        Text(opinion.localized)
                            .font(.montserratMedium, 10)
                            .foregroundStyle(Color.themeText)
                    }
                    .padding(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 80)
                    .background(Color.themeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    Text(comment)
                        .font(.montserratMedium, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                VStack(alignment: .leading, spacing: 4) {
                    feedbackInfo(feedback: feedback)
                }
            }
            .foregroundStyle(Color.themeTextSecondary)
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    func thumpsRow(thumps: ThumbsUpThumpsDown, optionalComment: String?) -> some View {
        if let comment = optionalComment {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    thumps.icon
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.top, 2)
                    Text(comment)
                        .font(.montserratMedium, 12)
                        .fixedSize(horizontal: false, vertical: true)
                }
                feedbackInfo(feedback: feedback)
            }
            .foregroundStyle(Color.themeTextSecondary.gradient)
            .padding(.vertical, 8)
        }
    }
    
    func feedbackInfo(feedback: Feedback) -> some View {
        HStack {
            if !feedback.seenByManager {
                Text("New")
                    .font(.montserratBold, 8)
                    .padding(2)
                    .padding(.horizontal, 4)
                    .foregroundStyle(Color.themeOnPrimaryAction)
                    .background(Color.themeBlue)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            }
            Text(feedback.createdAt.timeAgo())
                .font(.montserratRegular, 10)
            Spacer()
            
        }
    }
}

extension Emoji {
    var icon: Image {
        switch self {
        case .verySad:
            Image.verySad
        case .sad:
            Image.sad
        case .happy:
            Image.happy
        case .veryHappy:
            Image.veryHappy
        }
    }
}

extension ThumbsUpThumpsDown {
    var icon: Image {
        switch self {
        case .up:
            Image.thumpsUp
        case .down:
            Image.thumpsDown
        }
    }
}

#Preview("Emoji") {
    List {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                FeedbackCommentRowView(
                    feedback: .init(
                        type: FeedbackTypeWithData.emoji(emoji: .happy, comment: "Dope shit"),
                        questionId: UUID(),
                        seenByManager: false,
                        createdAt: Date()
                    )
                )
                
            }
            .padding(.top, 16)
            .foregroundStyle(Color.themeTextSecondary)
        }
    }
}

#Preview("Comment") {
    List {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                FeedbackCommentRowView(
                    feedback: .init(
                        type: FeedbackTypeWithData.comment(comment: "This is my dope comment"),
                        questionId: UUID(),
                        seenByManager: false,
                        createdAt: Date()
                    )
                )
                
            }
            .padding(.top, 16)
            .foregroundStyle(Color.themeTextSecondary)
        }
    }
}

#Preview("ZeroToTen") {
    List {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                FeedbackCommentRowView(
                    feedback: .init(
                        type: FeedbackTypeWithData.zeroToTen(zeroToTen: 5, comment: "cool comment"),
                        questionId: UUID(),
                        seenByManager: false,
                        createdAt: Date()
                    )
                )
                
            }
            .padding(.top, 16)
            .foregroundStyle(Color.themeTextSecondary)
        }
    }
}

#Preview("Opinion") {
    List {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                FeedbackCommentRowView(
                    feedback: .init(
                        type: FeedbackTypeWithData.opinion(opinion: Opinion.stronglyAgree, comment: "Dope shit"),
                        questionId: UUID(),
                        seenByManager: false,
                        createdAt: Date()
                    )
                )
            }
            .padding(.top, 16)
            .foregroundStyle(Color.themeTextSecondary)
        }
    }
}

#Preview("thumbsUpThumpsDown") {
    List {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                FeedbackCommentRowView(
                    feedback: .init(
                        type: FeedbackTypeWithData.thumpsUpThumpsDown(thumbsUpThumpsDown: .up, comment: "Cool comment"),
                        questionId: UUID(),
                        seenByManager: false,
                        createdAt: Date()
                    )
                )
                
            }
            .padding(.top, 16)
            .foregroundStyle(Color.themeTextSecondary)
        }
    }
}
