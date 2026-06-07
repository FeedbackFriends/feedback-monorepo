import Charts
import DesignSystem
import Domain
import SwiftUI

struct MeetingQualityPoint: Identifiable, Equatable {
    let eventId: Event.ID
    let date: Date
    let value: Double

    var id: Event.ID {
        eventId
    }
}

struct MeetingQualityCardView: View {
    let activity: Activity
    let showHowItWorks: () -> Void

    private var points: [MeetingQualityPoint] {
        activity.events
            .compactMap { event -> MeetingQualityPoint? in
                guard let averageRating = event.averageRating else { return nil }
                return MeetingQualityPoint(eventId: event.id, date: event.date, value: averageRating)
            }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if points.isEmpty {
                emptyState
            } else {
                MeetingQualityLineChartView(points: points)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityIdentifier("activity_detail_meeting_quality_card")
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingen feedbackgraf endnu")
                .rowTitleTextStyle()

            Text("Når sessioner har rating-feedback, vises udviklingen her.")
                .supportingTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showHowItWorks()
            } label: {
                Label("Fra kalender til feedback", systemImage: "questionmark.circle")
            }
            .buttonStyle(SecondaryTextButtonStyle())
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeBackground, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

struct MeetingQualityLineChartView: View {
    let points: [MeetingQualityPoint]
    @State private var selectedPointId: MeetingQualityPoint.ID?

    var body: some View {
        Chart {
            ForEach(points) { point in
                if points.count > 1 {
                    AreaMark(
                        x: .value("Session", xValue(for: point)),
                        yStart: .value("Bund", 0),
                        yEnd: .value("Feedbackscore", point.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.themeChartHighlighted.opacity(0.24),
                                Color.themeChartHighlighted.opacity(0.04)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Session", xValue(for: point)),
                        y: .value("Feedbackscore", point.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.themeChartHighlighted.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                }

                PointMark(
                    x: .value("Session", xValue(for: point)),
                    y: .value("Feedbackscore", point.value)
                )
                .foregroundStyle(Color.themeSurface)
                .symbolSize(point.id == latestPoint?.id ? 116 : 72)

                PointMark(
                    x: .value("Session", xValue(for: point)),
                    y: .value("Feedbackscore", point.value)
                )
                .foregroundStyle(Color.themeChartHighlighted.gradient)
                .symbolSize(point.id == latestPoint?.id ? 72 : 42)
            }

            if let selectedPoint {
                RuleMark(x: .value("Valgt session", xValue(for: selectedPoint)))
                    .foregroundStyle(Color.themeChartHighlighted.opacity(0.24))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 5]))

                PointMark(
                    x: .value("Valgt session", xValue(for: selectedPoint)),
                    y: .value("Feedbackscore", selectedPoint.value)
                )
                .foregroundStyle(Color.themeChartHighlighted.gradient)
                .symbolSize(150)
                .annotation(position: .top, alignment: annotationAlignment(for: selectedPoint), spacing: 8) {
                    selectedPointAnnotation(selectedPoint)
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                ZStack {
                    if let plotFrame = proxy.plotFrame,
                       let latestPoint,
                       selectedPoint?.id != latestPoint.id,
                       let latestX = proxy.position(forX: xValue(for: latestPoint)),
                       let latestY = proxy.position(forY: latestPoint.value) {
                        let frame = geometry[plotFrame]

                        Circle()
                            .stroke(Color.themeChartHighlighted.opacity(0.18), lineWidth: 14)
                            .frame(width: 28, height: 28)
                            .position(x: frame.minX + latestX, y: frame.minY + latestY)
                    }

                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    selectNearestPoint(to: value.location, proxy: proxy, geometry: geometry)
                                }
                        )
                }
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: 0...5)
        .chartYAxisLabel(position: .leading, alignment: .top) {
            Text("Score")
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 1, 2, 3, 4, 5]) {
                AxisGridLine()
                    .foregroundStyle(Color.themeTextSecondary.opacity(0.18))
                AxisValueLabel()
                    .foregroundStyle(Color.themeTextSecondary)
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisValues) { axisValue in
                AxisGridLine()
                    .foregroundStyle(Color.themeTextSecondary.opacity(0.08))
                AxisValueLabel {
                    if let index = axisValue.as(Double.self).map(Int.init),
                       points.indices.contains(index) {
                        Text(points[index].date.formatted(.dateTime.day().month()))
                            .foregroundStyle(Color.themeTextSecondary)
                    }
                }
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(
                    LinearGradient(
                        colors: [
                            Color.themeChartBackground,
                            Color.themeBackground.opacity(0.58)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        }
        .frame(height: 190)
        .accessibilityLabel("Feedback over tid")
        .accessibilityValue(accessibilitySummary)
    }

    @ViewBuilder
    private func selectedPointAnnotation(_ point: MeetingQualityPoint) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(String(format: "%.1f", point.value)) / 5")
                .captionTextStyle()
                .foregroundStyle(Color.themeText)

            Text(point.date.formatted(.dateTime.day().month()))
                .captionTextStyle()
                .foregroundStyle(Color.themeTextSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func selectNearestPoint(to location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }

        let frame = geometry[plotFrame]
        guard frame.insetBy(dx: -16, dy: -16).contains(location) else { return }

        let plotX = min(max(location.x - frame.minX, 0), frame.width)
        guard let selectedIndex = proxy.value(atX: plotX, as: Double.self),
              let nearestPoint = points.min(by: { lhs, rhs in
                  abs(xValue(for: lhs) - selectedIndex) < abs(xValue(for: rhs) - selectedIndex)
              }) else { return }

        selectedPointId = nearestPoint.id
    }

    private func xValue(for point: MeetingQualityPoint) -> Double {
        guard let index = points.firstIndex(where: { $0.id == point.id }) else { return 0 }
        return Double(index)
    }

    private func annotationAlignment(for point: MeetingQualityPoint) -> Alignment {
        guard points.count > 1,
              let index = points.firstIndex(where: { $0.id == point.id }) else {
            return .center
        }

        if index == points.startIndex {
            return .leading
        } else if index == points.index(before: points.endIndex) {
            return .trailing
        } else {
            return .center
        }
    }

    private var xDomain: ClosedRange<Double> {
        guard points.count > 1 else { return -0.5...0.5 }
        return 0...Double(points.count - 1)
    }

    private var xAxisValues: [Double] {
        guard points.count > 1 else { return [0] }

        let labelCount = min(points.count, 4)
        let lastIndex = points.count - 1
        let indexes = (0..<labelCount).map { labelIndex in
            Int((Double(labelIndex) * Double(lastIndex) / Double(labelCount - 1)).rounded())
        }

        return indexes.reduce(into: [Int]()) { uniqueIndexes, index in
            if uniqueIndexes.last != index {
                uniqueIndexes.append(index)
            }
        }
        .map(Double.init)
    }

    private var selectedPoint: MeetingQualityPoint? {
        guard let selectedPointId else { return nil }
        return points.first { $0.id == selectedPointId }
    }

    private var latestPoint: MeetingQualityPoint? {
        points.last
    }

    private var accessibilitySummary: String {
        guard let latestPoint = points.last else {
            return "Ingen sessioner med rating"
        }

        return "Seneste score \(String(format: "%.1f", latestPoint.value)) ud af 5"
    }
}

struct FocusMetricBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .captionTextStyle()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(Color.themeTextSecondary)
            .background(Color.themeBackground, in: Capsule())
    }
}
