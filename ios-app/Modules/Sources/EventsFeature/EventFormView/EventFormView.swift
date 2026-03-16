import ComposableArchitecture
import SwiftUI
import Domain
import Utility
import DesignSystem
import FeedbackFlowFeature

public struct EventFormView<ActionView: View>: View {
    
    @ViewBuilder let action: () -> ActionView
    @FocusState var focus: EventForm.FocusedField?
    @Bindable var store: StoreOf<EventForm>
    @Binding var showSuccessOverlay: Bool
    init(
        showSuccessOverlay: Binding<Bool>,
        store: StoreOf<EventForm>,
        action: @escaping () -> ActionView
        
    ) {
        self._showSuccessOverlay = showSuccessOverlay
        self.store = store
        self.action = action
    }
    
    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    
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
            store.send(.onAppear)
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
    }
    
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
                        recentlyUsedQuestions: self.store.recentlyUsedQuestions,
                        questionsInputs: self.$store.eventInput.questions,
                        presentFeedbackFlowSession: { feedbackSessionState in
                            self.store.send(.presentFeedbackFlowSession(feedbackSessionState))
                        }
                    )
                    .successOverlay(
                        message: store.successOverlayMessage,
                        show: $showSuccessOverlay,
                        enableAutomaticDismissal: false
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            action()
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                } label: {
                    Text("Next")
                }
                .buttonStyle(PrimaryTextButtonStyle())
                .disabled(store.eventInput.title.isEmpty)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}

private extension EventFormView {
    var content: some View {
        Section {
            TextField("Title", text: $store.eventInput.title)
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
                selection: $store.durationPicker, content: {
                    Text(EventForm.DurationPicker.minutes15.localization).tag(EventForm.DurationPicker.minutes15)
                    Text(EventForm.DurationPicker.minutes30.localization).tag(EventForm.DurationPicker.minutes30)
                    Text(EventForm.DurationPicker.minutes45.localization).tag(EventForm.DurationPicker.minutes45)
                    Text(EventForm.DurationPicker.minutes60.localization).tag(EventForm.DurationPicker.minutes60)
                    Text(EventForm.DurationPicker.minutes90.localization).tag(EventForm.DurationPicker.minutes90)
                    Text(EventForm.DurationPicker.minutes120.localization).tag(EventForm.DurationPicker.minutes120)
                    Text(EventForm.DurationPicker.other.localization).tag(EventForm.DurationPicker.other)
                }, label: {
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
                    }.pickerStyle(WheelPickerStyle())
                    Picker("", selection: $store.minutePicker) {
                        ForEach(0..<60, id: \.self) { number in
                            Text("\(number) min").tag(number)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }.padding(.horizontal)
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

#Preview {
    NavigationStack {
        EventFormView(
            showSuccessOverlay: .constant(false),
            store: StoreOf<EventForm>(initialState: .init(
                eventInput: EventInput(.mock()),
                startNowEnabled: false,
                focus: nil,
                shouldOpenKeyboardOnAppear: true,
                recentlyUsedQuestions: Set<RecentlyUsedQuestions>([]),
                successOverlayMessage: "Dope",
            )) {
                EventForm()
            }
        ) {
            Button {} label: {
                Text("Action")
            }
        }
    }
}
