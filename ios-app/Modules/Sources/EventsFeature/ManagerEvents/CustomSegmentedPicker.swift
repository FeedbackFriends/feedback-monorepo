import SwiftUI
import DesignSystem

public enum SegmentedControlMenu: Equatable, Sendable {
	case yourEvents
	case participating
}

struct CustomSegmentedPicker: View {
	
	@Binding var selectedSegmentedControl: SegmentedControlMenu
	@State var didAppear = false
	
	var yourOwnBackground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.clear
		case .yourEvents:
			Color.themePrimaryAction
		}
	}
	
	var yourOwnForeground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.themeText
		case .yourEvents:
			Color.themeOnPrimaryAction
		}
	}
	
	var selectedColor: Color {
		switch selectedSegmentedControl {
		case .yourEvents:
			yourOwnBackground
		case .participating:
			participatingBackground
		}
	}
	
	var participatingBackground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.themePrimaryAction
		case .yourEvents:
			Color.clear
		}
	}
	
	var participatingForeground: Color {
		switch selectedSegmentedControl {
		case .participating:
			Color.themeOnPrimaryAction
		case .yourEvents:
			Color.themeText
		}
	}
	
	var body: some View {
		ZStack {
			Capsule(style: .continuous)
				.frame(width: 180, height: 35, alignment: .center)
				.foregroundStyle(Color.themeBackground)
				.overlay(
					Capsule(style: .continuous)
						.stroke(Color.themeSurface, lineWidth: 3)
				)
			
			HStack {
				if case .participating = selectedSegmentedControl {
					Spacer()
				}
				Capsule(style: .continuous)
					.frame(width: 90, height: 35, alignment: .center)
					.foregroundStyle(selectedColor.gradient)
					.padding(.horizontal, 1)
				if case .yourEvents = selectedSegmentedControl {
					Spacer()
				}
			}
			.frame(width: 180, height: 35, alignment: .center)
			
			HStack(alignment: .center, spacing: 0) {
				Button("Your own") {
					self.selectedSegmentedControl = .yourEvents
				}
				.padding(10)
				.frame(width: 90, alignment: .center)
				.foregroundColor(yourOwnForeground)
				.clipShape(Capsule(style: .continuous))
				Button("Attending") {
					self.selectedSegmentedControl = .participating
				}
				.transition(.slide)
				.padding(10)
				.frame(width: 90, alignment: .center)
				.foregroundColor(participatingForeground)
				.clipShape(Capsule(style: .continuous))
			}
			.frame(height: 35)
			.foregroundStyle(Color.themeText)
			.font(.montserratMedium, 13)
			.background(Color.clear)
		}
		.offset(y: self.didAppear ? 0 : 200)
		.onAppear {
			Task {
				try await Task.sleep(for: .seconds(0.5))
				withAnimation(.bouncy(duration: 1)) {
					self.didAppear = true
				}
			}
		}
		.animation(.easeInOut(duration: 0.3), value: selectedSegmentedControl)
		.animation(.default, value: yourOwnForeground)
		.animation(.default, value: participatingForeground)
		
	}
}

#Preview {
	CustomSegmentedPicker(selectedSegmentedControl: .constant(.participating))
}
