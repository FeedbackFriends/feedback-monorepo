import SwiftUI
import DesignSystem

public struct FilterCollection: Equatable, Sendable {
	var allEnabled: Bool
	var todayEnabled: Bool
	var comingUpEnabled: Bool
	var previousEnabled: Bool
}

public extension FilterCollection {
	static let initial: FilterCollection = .init(
		allEnabled: true,
		todayEnabled: false,
		comingUpEnabled: false,
		previousEnabled: false
	)
}

struct TagFilterView: View {
	
	@Binding var filter: FilterCollection
	
	var allForeground: Color {
		filter.allEnabled ? Color.themeOnPrimaryAction : Color.themeTextSecondary
	}
	
	var todayForeground: Color {
		filter.todayEnabled ? Color.themeOnPrimaryAction : Color.themeTextSecondary
	}
	
	var comingUpForeground: Color {
		filter.comingUpEnabled ? Color.themeOnPrimaryAction : Color.themeTextSecondary
	}
	
	var previousForeground: Color {
		filter.previousEnabled ? Color.themeOnPrimaryAction : Color.themeTextSecondary
	}
	
	var body: some View {
		HStack {
			Button("All") {
				self.filter.allEnabled = true
				self.filter.comingUpEnabled = false
				self.filter.previousEnabled = false
				self.filter.todayEnabled = false
			}
			.padding(8)
			.padding(.horizontal, 4)
			.background(filter.allEnabled ? AnyView(Color.themePrimaryAction) : AnyView(Color.clear.glassEffect()))
			.foregroundStyle(allForeground)
			.cornerRadius(16)
			Button("Today") {
				self.filter.allEnabled = false
				self.filter.comingUpEnabled = false
				self.filter.previousEnabled = false
				self.filter.todayEnabled = true
			}
			.padding(8)
			.padding(.horizontal, 4)
			.background(filter.todayEnabled ? AnyView(Color.themePrimaryAction) : AnyView(Color.clear.glassEffect()))
			.foregroundStyle(todayForeground)
			.cornerRadius(16)
			Button("Coming up") {
				self.filter.allEnabled = false
				self.filter.comingUpEnabled = true
				self.filter.previousEnabled = false
				self.filter.todayEnabled = false
			}
			.padding(8)
			.padding(.horizontal, 4)
			.background(filter.comingUpEnabled ? AnyView(Color.themePrimaryAction) : AnyView(Color.clear.glassEffect()))
			.foregroundStyle(comingUpForeground)
			.cornerRadius(16)
			Button("Previous") {
				self.filter.allEnabled = false
				self.filter.comingUpEnabled = false
				self.filter.previousEnabled = true
				self.filter.todayEnabled = false
				
			}
			.padding(8)
			.padding(.horizontal, 4)
			.background(filter.previousEnabled ? AnyView(Color.themePrimaryAction) : AnyView(Color.clear.glassEffect()))
			.foregroundStyle(previousForeground)
			.cornerRadius(16)
			Spacer()
		}
		.sensoryFeedback(.selection, trigger: filter)
		.font(.montserratMedium, 13)
		.padding(.horizontal, 16)
	}
}
