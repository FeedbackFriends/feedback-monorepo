import ComposableArchitecture
import DesignSystem
import Domain
import Localization
import SwiftUI

public struct ProductContactView: View {
    @Bindable var store: StoreOf<ProductContact>
    @FocusState private var messageFocused: Bool
    @FocusState private var expectedFocused: Bool
    @FocusState private var emailFocused: Bool

    public init(store: StoreOf<ProductContact>) { self.store = store }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if store.receipt != nil {
                        confirmation
                    } else {
                        form
                    }
                }
                .frame(maxWidth: Constants.maxWidthForLargeDevices)
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle(String(appStrings: store.kind == .productFeedback ? .moreSendFeedback : .moreReportBug))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButtonView { store.send(.closeTapped) }
                }
            }
            .safeAreaInset(edge: .bottom) { primaryAction }
            .alert($store.scope(state: \.alert, action: \.alert))
            .sheet(item: Binding(
                get: { store.mailDraft },
                set: { if $0 == nil { store.send(.mailDismissed) } }
            )) { draft in
                MailComposerView(recipient: draft.recipient, subject: draft.subject, message: draft.message) {
                    store.send(.mailFinished(failed: $0))
                }
            }
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 20) {
            if store.kind == .productFeedback {
                Text(String(appStrings: .productContactFeedbackQuestion)).titleTextStyle()
                EmojiRatingView(selected: store.rating) { store.send(.ratingTapped($0), animation: .bouncy) }
                    .disabled(!store.canEdit)
                Text(String(appStrings: .productContactFeedbackHelp)).supportingTextStyle()
            }
            TextInputView(
                title: String(appStrings: store.kind == .productFeedback ? .productContactComment : .productContactBugDescription),
                prompt: String(appStrings: store.kind == .productFeedback ? .productContactCommentPrompt : .productContactBugPrompt),
                text: binding(\.message, field: .message), isFocused: $messageFocused,
                axis: .vertical, lineLimit: 3...10, accessibilityIdentifier: "support_message_input"
            )
            .disabled(!store.canEdit)
            if store.kind == .bugReport {
                TextInputView(
                    title: String(appStrings: .productContactExpectedBehavior),
                    prompt: String(appStrings: .productContactExpectedPrompt),
                    text: binding(\.expectedBehavior, field: .expectedBehavior), isFocused: $expectedFocused,
                    axis: .vertical, lineLimit: 2...6, accessibilityIdentifier: "support_expected_input"
                )
                .disabled(!store.canEdit)
                emailField
            }
            Text(String(appStrings: .productContactTextLimit))
                .supportingTextStyle()
                .foregroundStyle(store.message.utf16.count > 5000 || store.expectedBehavior.utf16.count > 5000
                    ? Color.themeSad : Color.themeTextSecondary)
            if let error = store.error {
                VStack(alignment: .leading, spacing: 8) {
                    Text(error.title).rowTitleTextStyle()
                    Text(error.message).bodyTextStyle()
                }
                .surfaceCard()
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("support_submission_error")
            }
            Button(String(appStrings: .productContactMailInstead)) { store.send(.mailInsteadTapped) }
                .buttonStyle(SecondaryTextButtonStyle())
                .disabled(!store.canEdit || store.isCheckingMail)
                .accessibilityIdentifier("support_mail_instead_button")
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(appStrings: .productContactEmail)).rowTitleTextStyle()
                TextField("", text: binding(\.contactEmail, field: .contactEmail))
                    .textInputTextStyle()
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .focused($emailFocused)
                    .accessibilityLabel(String(appStrings: .productContactEmail))
                    .accessibilityIdentifier("support_contact_email_input")
            }
            .surfaceCard(padding: 15)
            .disabled(!store.canEdit)
            Text(String(appStrings: store.isEmailValid ? .productContactEmailHelp : .productContactEmailInvalid))
                .supportingTextStyle()
                .foregroundStyle(store.isEmailValid ? Color.themeTextSecondary : Color.themeSad)
        }
    }

    private var confirmation: some View {
        VStack(spacing: 20) {
            Image.checkmarkCircleFill
                .resizable().scaledToFit().frame(width: 60, height: 60)
                .foregroundStyle(Color.themePrimaryAction)
                .accessibilityHidden(true)
            Text(String(appStrings: .productContactThankYou)).titleTextStyle()
            Text(String(appStrings: .productContactReceived)).bodyTextStyle()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .accessibilityIdentifier("support_submission_confirmation")
    }

    private var primaryAction: some View {
        Group {
            if store.receipt != nil {
                Button(String(appStrings: .commonClose)) { store.send(.closeTapped) }
            } else {
                Button(String(appStrings: .productContactSend)) {
                    messageFocused = false
                    expectedFocused = false
                    emailFocused = false
                    store.send(.sendTapped)
                }
                .isLoading(store.isSending)
                .disabled(!store.isValid || !store.canEdit || store.isCheckingMail)
                .accessibilityIdentifier("support_submit_button")
            }
        }
        .buttonStyle(LargeButtonStyle())
        .padding(Theme.padding)
        .frame(maxWidth: .infinity)
        .background(Color.themeBackground)
    }

    private func binding(_ keyPath: KeyPath<ProductContact.State, String>, field: ProductContact.Field) -> Binding<String> {
        Binding(get: { store.state[keyPath: keyPath] }, set: { store.send(.inputChanged(field, $0)) })
    }
}
