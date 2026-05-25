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
        Form {
            content
        }
        .synchronize($store.focus, $focus)
        .background(Color.themeBackground.ignoresSafeArea())
        .toolbar {
            toolbarItems
        }
        .foregroundColor(.themeText)
        .font(.montserratMedium, 14)
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
                        .font(.montserratSemiBold, 12)
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
        .scrollContentBackground(.hidden)
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
        Section {
            TextField("Title", text: $store.eventInput.title)
                .accessibilityIdentifier("event_form_title_input")
                .focused($focus, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    store.send(.onSubmitTitleTextField)
                }
            TextField("Agenda (optional)", text: $store.eventInput.agenda.asNonOptional(), axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .submitLabel(.return)
                .focused($focus, equals: .description)
            Toggle(isOn: $store.allDay) {
                Text("All day")
            }
            durationPickerView
        } header: {
            Text("Details")
                .sectionHeaderStyle()
                .padding(.leading, 12)
        }
        .animation(.default, value: store.startNowEnabled)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    var durationPickerView: some View {
        if !store.allDay {
            Toggle(isOn: $store.startNowEnabled) {
                Text("Start now")
            }
            if !store.startNowEnabled {
                DatePicker(
                    selection: $store.eventInput.date,
                    in: store.date.roundedUpcoming5Min()...,
                    displayedComponents: [DatePickerComponents.date, DatePickerComponents.hourAndMinute]
                ) {
                    Text("Time")
                }
            }
            Picker(
                selection: $store.durationPicker,
                content: {
                    Text(ManageEvent.State.DurationPicker.minutes15.localization).tag(ManageEvent.State.DurationPicker.minutes15)
                    Text(ManageEvent.State.DurationPicker.minutes30.localization).tag(ManageEvent.State.DurationPicker.minutes30)
                    Text(ManageEvent.State.DurationPicker.minutes45.localization).tag(ManageEvent.State.DurationPicker.minutes45)
                    Text(ManageEvent.State.DurationPicker.minutes60.localization).tag(ManageEvent.State.DurationPicker.minutes60)
                    Text(ManageEvent.State.DurationPicker.minutes90.localization).tag(ManageEvent.State.DurationPicker.minutes90)
                    Text(ManageEvent.State.DurationPicker.minutes120.localization).tag(ManageEvent.State.DurationPicker.minutes120)
                    Text(ManageEvent.State.DurationPicker.other.localization).tag(ManageEvent.State.DurationPicker.other)
                },
                label: {
                    Text("Duration")
                        .foregroundColor(.themeText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            )
            if case .other = store.durationPicker {
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
                .padding(.horizontal)
                .font(.montserratRegular, 12)
                .frame(height: 140)
            }
        } else {
            DatePicker(
                selection: $store.eventInput.date,
                in: store.date...,
                displayedComponents: [DatePickerComponents.date]
            ) {
                Text("Time")
            }
        }
    }
}
