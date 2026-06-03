import ComposableArchitecture
import DesignSystem
import Domain
import Utility
import SwiftUI

public struct ManageEventView: View {
    @Bindable var store: StoreOf<ManageEvent>

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
        .background(Color.themeBackground.ignoresSafeArea())
        .successOverlay(
            message: store.successOverlayMessage,
            show: $store.showSuccessOverlay,
            enableAutomaticDismissal: false
        )
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
        .alert($store.scope(state: \.alert, action: \.alert))
        .navigationTitle(store.navigationTitle)
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
                Button(store.actionButtonTitle) {
                    store.send(.actionButtonTap)
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .isLoading(store.manageEventInFlight)
                .disabled(store.manageEventButtonDisabled)
                .accessibilityIdentifier("event_form_save_button")
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            section(title: "Tid og sted") {
                inputField(
                    title: "Lokation",
                    prompt: "Lokation (valgfrit)",
                    text: $store.eventInput.location.asNonOptional(),
                    accessibilityIdentifier: "event_form_location_input"
                )

                sectionDivider

                eventTimeFields
            }

            feedbackSetupSection
        }
    }

    @ViewBuilder
    var eventTimeFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $store.allDay) {
                Text("Hele dagen")
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
            }
            .tint(Color.themePrimaryAction)

            durationPickerView
        }
        .animation(.default, value: store.startNowEnabled)
    }

    var feedbackSetupSection: some View {
        section(title: "Feedbackopsætning") {
            VStack(alignment: .leading, spacing: 10) {
                Text(store.eventInput.title)
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Denne mødegang bruger feedbackspørgsmålene fra formatet.")
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let agenda = store.eventInput.agenda, !agenda.isEmpty {
                    Text(agenda)
                        .supportingTextStyle()
                        .foregroundStyle(Color.themeTextSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                    Text(questionCountText)
                }
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.themeBackground, in: Capsule())

                Text("Rediger formatet, hvis spørgsmålene skal ændres for kommende mødegange.")
                    .supportingTextStyle()
                    .foregroundStyle(Color.themeTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            sectionDivider

            Button {
                store.send(.editActivityButtonTap)
            } label: {
                Label("Rediger format", systemImage: "pencil")
            }
            .buttonStyle(SecondaryTextButtonStyle())
            .accessibilityIdentifier("event_form_edit_activity_button")
        }
    }

    var questionCountText: String {
        let count = store.eventInput.questions.count
        return count == 1 ? "1 spørgsmål" : "\(count) spørgsmål"
    }

    @ViewBuilder
    var durationPickerView: some View {
        if !store.allDay {
            sectionDivider

            Toggle(isOn: $store.startNowEnabled) {
                Text("Start nu")
                    .rowTitleTextStyle()
                    .foregroundStyle(Color.themeText)
            }
            .tint(Color.themePrimaryAction)

            if !store.startNowEnabled {
                sectionDivider

                datePickerRow(
                    title: "Tidspunkt",
                    selection: $store.eventInput.date,
                    range: store.date.roundedUpcoming5Min()...,
                    displayedComponents: [DatePickerComponents.date, DatePickerComponents.hourAndMinute]
                )
            }

            sectionDivider

            HStack {
                Text("Varighed")
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
                        Text("Varighed")
                    }
                )
                .pickerStyle(.menu)
                .supportingTextStyle()
            }

            if case .other = store.durationPicker {
                sectionDivider

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tilpasset varighed")
                        .rowTitleTextStyle()

                    HStack {
                        Picker("", selection: $store.hourPicker) {
                            ForEach(0..<24, id: \.self) { number in
                                Text(number == 1 ? "1 time" : "\(number) timer").tag(number)
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
