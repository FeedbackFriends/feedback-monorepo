import ComposableArchitecture
import DesignSystem
import Domain
import FeedbackFlowFeature
import Utility
import SwiftUI

public struct ManageEventView: View {
    @Bindable var store: StoreOf<ManageEvent>
    @FocusState private var focus: ManageEvent.State.FocusedField?

    public init(store: StoreOf<ManageEvent>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .frame(maxWidth: Constants.maxWidthForLargeDevices)
            .padding(.horizontal, Theme.padding)
            .padding(.top, Theme.padding)
            .padding(.bottom, Theme.padding)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .synchronize($store.focus, $focus)
        .background(Color.themeBackground.ignoresSafeArea())
        .toolbar {
            toolbarItems
        }
        .foregroundStyle(Color.themeText)
        .bodyTextStyle()
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
        .onChange(of: store.minutePicker) { _, _ in
            store.send(.minutePickerChanged)
        }
        .onChange(of: store.hourPicker) { _, _ in
            store.send(.hourPickerChanged)
        }
        .onChange(of: store.allDay) { _, _ in
            store.send(.allDayChanged)
        }
        .onChange(of: store.durationPicker) { _, newValue in
            store.send(.durationPickerChanged(newValue))
        }
        .sheet(
            item: $store.scope(
                state: \.feedbackFlowCoordinator,
                action: \.feedbackFlowCoordinator
            )
        ) { store in
            FeedbackFlowCoordinatorView(
                store: store,
                principalToolbarItem: {
                    Text("Preview")
                        .captionTextStyle()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.themeBlue.gradient)
                        .foregroundStyle(Color.themeOnPrimaryAction)
                        .clipShape(Capsule())
                }
            )
        }
        .navigationBarTitle(store.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ManageEventView {
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                CloseButtonView {
                    store.send(.closeButtonTap)
                }
                .buttonStyle(SecondaryTextButtonStyle())
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    QuestionsListView(
                        questionsInputs: $store.eventInput.questions,
                        previewConfiguration: .init(
                            title: store.eventInput.title,
                            agenda: store.eventInput.agenda,
                            presentFeedbackFlowSession: { feedbackSessionState in
                                store.send(.presentFeedbackFlowSession(feedbackSessionState))
                            }
                        )
                    )
                    .successOverlay(
                        message: store.successOverlayMessage,
                        show: $store.showSuccessOverlay,
                        enableAutomaticDismissal: false
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(store.actionButtonTitle) {
                                store.send(.actionButtonTap)
                            }
                            .buttonStyle(PrimaryTextButtonStyle())
                            .isLoading(store.manageEventInFlight)
                            .disabled(store.manageEventButtonDisabled)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                    .alert($store.scope(state: \.alert, action: \.alert))
                } label: {
                    Text("Next")
                }
                .accessibilityIdentifier("event_form_next")
                .buttonStyle(PrimaryTextButtonStyle())
                .disabled(store.eventInput.title.isEmpty)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }

    var content: some View {
        section(title: "Details") {
            inputField(
                title: "Title",
                prompt: "Session title",
                text: $store.eventInput.title,
                accessibilityIdentifier: "event_form_title_input"
            )
            .focused($focus, equals: .title)
            .submitLabel(.next)
            .onSubmit {
                store.send(.onSubmitTitleTextField)
            }

            sectionDivider

            inputField(
                title: "Agenda",
                prompt: "Agenda (optional)",
                text: $store.eventInput.agenda.asNonOptional(),
                axis: .vertical,
                lineLimit: 2...2
            )
            .submitLabel(.return)
            .focused($focus, equals: .description)

            sectionDivider

            Toggle(isOn: $store.allDay) {
                Text("All day")
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
            }
            .tint(Color.themePrimaryAction)

            durationPickerView
        }
        .animation(.default, value: store.startNowEnabled)
    }

    @ViewBuilder
    var durationPickerView: some View {
        if !store.allDay {
            sectionDivider

            Toggle(isOn: $store.startNowEnabled) {
                Text("Start now")
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
            }
            .tint(Color.themePrimaryAction)

            if !store.startNowEnabled {
                sectionDivider

                datePickerRow(
                    title: "Time",
                    selection: $store.eventInput.date,
                    range: store.date.roundedUpcoming5Min()...,
                    displayedComponents: [DatePickerComponents.date, DatePickerComponents.hourAndMinute]
                )
            }

            sectionDivider

            HStack {
                Text("Duration")
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)

                Spacer()

                Picker(
                    selection: $store.durationPicker,
                    content: {
                        Text(ManageEvent.State.DurationPicker.minutes15.localization)
                            .tag(ManageEvent.State.DurationPicker.minutes15)
                        Text(ManageEvent.State.DurationPicker.minutes30.localization)
                            .tag(ManageEvent.State.DurationPicker.minutes30)
                        Text(ManageEvent.State.DurationPicker.minutes45.localization)
                            .tag(ManageEvent.State.DurationPicker.minutes45)
                        Text(ManageEvent.State.DurationPicker.minutes60.localization)
                            .tag(ManageEvent.State.DurationPicker.minutes60)
                        Text(ManageEvent.State.DurationPicker.minutes90.localization)
                            .tag(ManageEvent.State.DurationPicker.minutes90)
                        Text(ManageEvent.State.DurationPicker.minutes120.localization)
                            .tag(ManageEvent.State.DurationPicker.minutes120)
                        Text(ManageEvent.State.DurationPicker.other.localization)
                            .tag(ManageEvent.State.DurationPicker.other)
                    },
                    label: {
                        Text("Duration")
                    }
                )
                .pickerStyle(.menu)
                .supportingTextStyle()
            }

            if case .other = store.durationPicker {
                sectionDivider

                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom duration")
                        .rowTitleTextStyle()

                    HStack {
                        Picker("", selection: $store.hourPicker) {
                            ForEach(0..<24, id: \.self) { number in
                                Text("\(number) hours").tag(number)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())

                        Picker("", selection: $store.minutePicker) {
                            ForEach(0..<60, id: \.self) { number in
                                Text("\(number) min").tag(number)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                    .supportingTextStyle()
                    .frame(height: 140)
                }
            }
        } else {
            sectionDivider

            datePickerRow(
                title: "Time",
                selection: $store.eventInput.date,
                range: store.date...,
                displayedComponents: [DatePickerComponents.date]
            )
        }
    }

    @ViewBuilder
    func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            SectionHeaderView(title)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.themeSurface)
            .cornerRadius(14)
        }
    }

    @ViewBuilder
    func inputField(
        title: String,
        prompt: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        lineLimit: ClosedRange<Int>? = nil,
        accessibilityIdentifier: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .rowTitleTextStyle()
                .foregroundStyle(Color.themeText)

            TextField(
                "",
                text: text,
                prompt: Text(prompt)
                    .foregroundStyle(Color.themeTextSecondary),
                axis: axis
            )
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
            .supportingTextStyle()
            .foregroundStyle(Color.themeTextSecondary)
            .lineLimit(lineLimit ?? 1...1)
        }
    }

    func datePickerRow(
        title: String,
        selection: Binding<Date>,
        range: PartialRangeFrom<Date>,
        displayedComponents: DatePickerComponents
    ) -> some View {
        HStack {
            Text(title)
                .rowTitleTextStyle()
                .foregroundStyle(Color.themeText)

            Spacer()

            DatePicker(
                "",
                selection: selection,
                in: range,
                displayedComponents: displayedComponents
            )
            .labelsHidden()
            .supportingTextStyle()
        }
    }

    var sectionDivider: some View {
        Rectangle()
            .fill(Color.themeBackground)
            .frame(height: 1)
    }
}
