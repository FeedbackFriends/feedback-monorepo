import ComposableArchitecture
import DesignSystem
import Foundation
import SwiftUI

public struct FeedbackFlowCoordinatorView<PrincipalToolbarItem: View>: View {
    @Bindable var store: StoreOf<FeedbackFlowCoordinator>
    @FocusState var commentTextfieldFocused: Bool
    @ViewBuilder var principalToolbarItem: () -> PrincipalToolbarItem
    var showNavigateBackButton: Bool {
        store.questionIndex != 0
    }
    var showSubmitButton: Bool {
        store.questions.count - 1 == store.questionIndex
    }
    var disableNextButton: Bool {
        !store.feedbackItemCompleted
    }
    var disableSubmitButton: Bool {
        !store.feedbackItemCompleted
    }
    
    public init(store: StoreOf<FeedbackFlowCoordinator>, principalToolbarItem: @escaping () -> PrincipalToolbarItem) {
        self.store = store
        self.principalToolbarItem = principalToolbarItem
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ProgressView()
        } destination: { store in
            VStack(spacing: 0) {
                questionView
                    .padding(.top, 20)
                switch store.case {
                case let .emoji(store):
                    EmojiFeedbackView(
                        store: store,
                        commentTextfieldFocused: $commentTextfieldFocused
                    )
                case let .zeroToTen(store):
                    ZeroToTenFeedbackView(
                        store: store,
                        commentTextfieldFocused: $commentTextfieldFocused
                    )
                case let .thumpsUpThumpsDown(store):
                    ThumpsFeedbackView(
                        store: store,
                        commentTextfieldFocused: $commentTextfieldFocused
                    )
                    
                case let .comment(store):
                    CommentFeedbackView(
                        store: store,
                        commentTextfieldFocused: $commentTextfieldFocused
                    )
                    
                case let .opinion(store):
                    OpinionFeedbackView(
                        store: store,
                        commentTextfieldFocused: $commentTextfieldFocused
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Quit") {
                        self.store.send(.dismissButtonTap)
                    }
                    .buttonStyle(SecondaryTextButtonStyle())
                    .foregroundStyle(Color.themeText)
                }
                ToolbarItem(placement: .principal) {
                    principalToolbarItem()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.store.send(.infoButtonTap)
                    } label: {
                        Image.info
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.themeText)
                            .padding(4)
                    }
                }
            }
            .padding(.bottom, 90)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.themeGradientBlue, location: 0.0),
                        .init(color: Color.themeGradientBlue, location: 0.2),
                        .init(color: Color.themeGradientRed, location: 0.8),
                        .init(color: Color.themeGradientRed, location: 1.0)
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
            )
            .navigationBarBackButtonHidden(true)
        }
        .overlay(alignment: .bottom) {
            bottomBar
        }
        .animation(.smooth, value: commentTextfieldFocused)
        .synchronize($store.commentTextfieldFocused, self.$commentTextfieldFocused)
        .sheet(
            item: $store.scope(
                state: \.destination?.ratingPrompt,
                action: \.destination.ratingPrompt
            ),
            onDismiss: {
                store.send(.ratingPromptDismissed)
            },
            content: { _ in
                RatingAlertView()
                    .presentationDetents([.height(300)])
            }
        )
        .sensoryFeedback(.selection, trigger: store.questionIndex)
        .statusBar(hidden: true)
        .successOverlay(
            message: "Thanks for the feedback",
            show: $store.presentSuccessOverlay,
            enableAutomaticDismissal: false
        )
        .sheet(
            item: $store.scope(state: \.destination?.showEventInfo, action: \.destination.showEventInfo),
            content: { _ in
                EventInfoView(
                    eventTitle: store.title,
                    eventAgenda: store.agenda,
                    ownerName: store.ownerInfo.name,
                    ownerEmail: store.ownerInfo.email,
                    ownerphoneNumber: store.ownerInfo.phoneNumber,
                    date: store.date
                )
                .presentationDetents([.medium])
            }
        )
        
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
    
    var questionView: some View {
        VStack {
            Text("\(store.questionIndex + 1) of \(store.questions.count)")
                .font(.montserratBold, 12)
                .foregroundColor(Color.themeTextSecondary)
                .padding(.top, 8)
                .animation(.snappy, value: store.questionIndex)
            Text(store.questionText)
                .padding(.horizontal, 24)
                .font(.montserratRegular, 15)
                .foregroundColor(Color.themeText)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
                .padding(.top, 4)
        }
    }
    
    var bottomBar: some View {
        HStack {
            if showNavigateBackButton {
                Button {
                    store.send(.previousQuestionButtonTap)
                } label: {
                    Image.arrowBackwards
                        .resizable()
                        .frame(width: 30, height: 30)
                        .fontWeight(Font.Weight.semibold)
                        .foregroundColor(Color.themeText)
                }
                .transition(.blurReplace)
                .padding(.trailing, 10)
                .buttonStyle(OpacityButtonStyle())
            }
            if showSubmitButton {
                Button("Submit") {
                    store.send(.submitButtonTap)
                }
                .buttonStyle(LargeButtonStyle())
                .disabled(disableSubmitButton)
                .isLoading(store.submitFeedbackInFlight)
                .transition(.blurReplace)
            } else {
                Button("Next") {
                    store.send(.nextQuestionButtonTap)
                }
                .buttonStyle(LargeButtonStyle())
                .disabled(disableNextButton)
                .transition(.blurReplace)
            }
        }
        .padding(.vertical, Theme.padding)
        .padding(.horizontal, Theme.padding)
        .animation(.bouncy, value: showSubmitButton)
        .animation(.bouncy, value: showNavigateBackButton)
    }
}

#Preview("Flow") {
    FeedbackFlowCoordinatorView(
        store: Store(
            initialState: FeedbackFlowCoordinator.State.initialState(
                feedbackSession: .mock
            )
        ) {
            FeedbackFlowCoordinator()
        },
        principalToolbarItem: {
            Text("Hello")
        }
    )
}
