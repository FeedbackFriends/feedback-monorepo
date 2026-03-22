import SwiftUI

// MARK: - View

struct CreateFocusView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""

    @State private var selectedTemplate: FeedbackTemplate = .quickFeedback
    @State private var selectedRunMode: RunMode = .manual
    @State private var repeatOption: RepeatOption = .weeklyFriday

    // Email bot
    @State private var showInfoSheet = false
    @State private var didCopyEmail = false
    private let botEmail = "feedback@letsgrow.dk"

    // Invitations
    @State private var sendEmails = false
    @State private var participants: [String] = []
    @State private var newEmail = ""

    var onCreate: ((CreateFocusData) -> Void)?

    private var isCreateDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - What is this?
                Section {
                    TextField("What do you want feedback on?", text: $title)

                    TextField("Add context (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                // MARK: - How feedback is shared 🔥
                Section { //("Feedback delivery") {

                    Toggle("Send email invitations", isOn: $sendEmails)

                    if sendEmails {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add participants")
                                .font(.subheadline.weight(.semibold))

                            HStack {
                                TextField("Add email", text: $newEmail)

                                Button("Add") {
                                    let trimmed = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }

                                    participants.append(trimmed)
                                    newEmail = ""
                                }
                                .disabled(newEmail.trimmingCharacters(in: .whitespaces).isEmpty)
                            }

                            ForEach(participants, id: \.self) { email in
                                HStack {
                                    Text(email)

                                    Spacer()

                                    Button {
                                        participants.removeAll { $0 == email }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                } footer: {
                    Text(deliveryFooterText)
                }

                // MARK: - How it runs
                Section { //Section("How it runs") {
                    ForEach(RunMode.allCases) { mode in
                        SelectableRow(
                            title: mode.title,
                            subtitle: mode.subtitle,
                            icon: mode.icon,
                            isSelected: selectedRunMode == mode
                        ) {
                            selectedRunMode = mode
                        }
                    }

                    if selectedRunMode == .recurring {
                        Picker("Repeat", selection: $repeatOption) {
                            ForEach(RepeatOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    }

                    if selectedRunMode == .automatic {
                        VStack(alignment: .leading, spacing: 12) {

                            Text("Create sessions automatically")
                                .font(.subheadline.weight(.semibold))

                            Text("Add this email to your calendar event")
                                .foregroundStyle(.secondary)

                            HStack {
                                Text(botEmail)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.thinMaterial, in: Capsule())

                                Spacer()

                                Button {
                                    UIPasteboard.general.string = botEmail
                                    didCopyEmail = true
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                .buttonStyle(.bordered)
                            }

                            if didCopyEmail {
                                Text("Email copied. Paste it into your calendar event.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Button("How it works") {
                                showInfoSheet = true
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 6)
                    }
                }

                // MARK: - Feedback Setup
                Section { //Section("How feedback works") {
                    ForEach(FeedbackTemplate.allCases) { template in
                        SelectableRow(
                            title: template.title,
                            subtitle: template.subtitle,
                            icon: template.icon,
                            isSelected: selectedTemplate == template
                        ) {
                            selectedTemplate = template
                        }
                    }
                } footer: {
                    Text("You can always change questions later.")
                }

                // MARK: - Preview
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This will be asked after each session")
                            .font(.subheadline.weight(.semibold))

                        ForEach(selectedTemplate.previewQuestions, id: \.self) { question in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                                    .font(.caption)

                                Text(question)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let data = CreateFocusData(
                            title: title,
                            description: description,
                            template: selectedTemplate,
                            runMode: selectedRunMode,
                            repeatOption: repeatOption,
                            participants: sendEmails ? participants : [],
                            sendEmails: sendEmails
                        )

                        onCreate?(data)
                        dismiss()
                    }
                    .disabled(isCreateDisabled)
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                AutomaticInfoSheet(email: botEmail)
            }
        }
    }

    private var deliveryFooterText: String {
        if sendEmails {
            return "We’ll email participants after each session."
        } else {
            return "You’ll share a feedback link manually."
        }
    }
}

//
// MARK: - Models
//

struct CreateFocusData {
    let title: String
    let description: String
    let template: FeedbackTemplate
    let runMode: RunMode
    let repeatOption: RepeatOption
    let participants: [String]
    let sendEmails: Bool
}

//
// MARK: - Supporting Views
//

private struct SelectableRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 28)

                VStack(alignment: .leading) {
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .gray)
            }
        }
        .buttonStyle(.plain)
    }
}

//
// MARK: - Info Sheet
//

struct AutomaticInfoSheet: View {
    let email: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                Text("Automatic sessions")
                    .font(.title2.bold())

                Text("1. Add \(email) to your event\n2. We create the session\n3. Feedback is sent after")

                Spacer()

                Button("Copy email") {
                    UIPasteboard.general.string = email
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

//
// MARK: - Enums
//

enum RunMode: String, CaseIterable, Identifiable {
    case manual, recurring, automatic
    var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: return "Manual"
        case .recurring: return "Recurring"
        case .automatic: return "Automatic"
        }
    }

    var subtitle: String {
        switch self {
        case .manual: return "Start sessions yourself"
        case .recurring: return "Create sessions on a schedule"
        case .automatic: return "Use your calendar"
        }
    }

    var icon: String {
        switch self {
        case .manual: return "hand.tap"
        case .recurring: return "repeat"
        case .automatic: return "envelope.badge"
        }
    }
}

enum RepeatOption: String, CaseIterable, Identifiable {
    case weeklyFriday
    var id: String { rawValue }

    var title: String { "Every Friday" }
}

enum FeedbackTemplate: String, CaseIterable, Identifiable {
    case quickFeedback
    case engagement
    case learning
    case retrospective
    case leadership

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quickFeedback: return "Quick feedback"
        case .engagement: return "Engagement"
        case .learning: return "Learning"
        case .retrospective: return "Retrospective"
        case .leadership: return "Leadership"
        }
    }

    var subtitle: String {
        switch self {
        case .quickFeedback:
            return "Fast rating with optional comment"
        case .engagement:
            return "Energy and participation"
        case .learning:
            return "Clarity and usefulness"
        case .retrospective:
            return "Reflect and improve as a team"
        case .leadership:
            return "Feedback on leadership and direction"
        }
    }

    var icon: String {
        switch self {
        case .quickFeedback: return "bolt"
        case .engagement: return "person.2"
        case .learning: return "lightbulb"
        case .retrospective: return "arrow.clockwise"
        case .leadership: return "person.crop.circle.badge.checkmark"
        }
    }

    var previewQuestions: [String] {
        switch self {
        case .quickFeedback:
            return [
                "How was this session? (1–5)",
                "What went well?",
                "What could be improved?"
            ]

        case .engagement:
            return [
                "How was the energy? (1–5)",
                "Did you feel involved?",
                "What affected engagement?"
            ]

        case .learning:
            return [
                "How clear was it? (1–5)",
                "How useful was it? (1–5)",
                "What is still unclear?"
            ]

        case .retrospective:
            return [
                "What worked well?",
                "What could be better?",
                "Overall rating (1–5)"
            ]

        case .leadership:
            return [
                "Did you feel well guided?",
                "Was communication clear?",
                "What could be improved in leadership?"
            ]
        }
    }
}

#Preview {
    CreateFocusView { _ in }
}
