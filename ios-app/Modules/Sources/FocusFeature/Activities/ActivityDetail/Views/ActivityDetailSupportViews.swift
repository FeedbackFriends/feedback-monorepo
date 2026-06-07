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

private enum MeetingQualityAnnotationEdge {
    case leading
    case center
    case trailing
}

struct MeetingQualityCardView: View {
    let activity: Activity
    let showHowItWorks: () -> Void
    let onEventTap: (Event) -> Void

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
            MeetingQualityLineChartView(
                points: points,
                onPointTap: { point in
                    guard let event = activity.events.first(where: { $0.id == point.eventId }) else { return }
                    onEventTap(event)
                }
            )
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .accessibilityIdentifier("activity_detail_meeting_quality_card")
    }
}

struct MeetingQualityLineChartView: View {
    let points: [MeetingQualityPoint]
    let onPointTap: (MeetingQualityPoint) -> Void
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
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                ZStack {
                    if let plotFrame = proxy.plotFrame,
                       let latestPoint,
                       let latestX = proxy.position(forX: xValue(for: latestPoint)),
                       let latestY = proxy.position(forY: latestPoint.value) {
                        let frame = geometry[plotFrame]

                        Circle()
                            .stroke(Color.themeChartHighlighted.opacity(0.18), lineWidth: 14)
                            .frame(width: 28, height: 28)
                            .position(x: frame.minX + latestX, y: frame.minY + latestY)
                    }

                    if let plotFrame = proxy.plotFrame {
                        let frame = geometry[plotFrame]

                        ForEach(points) { point in
                            if let xPosition = proxy.position(forX: xValue(for: point)),
                               let yPosition = proxy.position(forY: point.value) {
                                Button {
                                    selectedPointId = point.id
                                } label: {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .position(x: frame.minX + xPosition, y: frame.minY + yPosition)
                                .accessibilityLabel(pointSelectionAccessibilityLabel(point))
                            }
                        }

                        if let selectedPoint,
                           let xPosition = proxy.position(forX: xValue(for: selectedPoint)),
                           let yPosition = proxy.position(forY: selectedPoint.value) {
                            selectedPointAnnotation(selectedPoint)
                                .position(
                                    annotationPosition(
                                        for: selectedPoint,
                                        pointPosition: CGPoint(
                                            x: frame.minX + xPosition,
                                            y: frame.minY + yPosition
                                        ),
                                        plotFrame: frame
                                    )
                                )
                        }
                    }
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
        Button {
            onPointTap(point)
        } label: {
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
        .buttonStyle(OpacityButtonStyle())
        .accessibilityLabel(pointNavigationAccessibilityLabel(point))
    }

    private func xValue(for point: MeetingQualityPoint) -> Double {
        guard let index = points.firstIndex(where: { $0.id == point.id }) else { return 0 }
        return Double(index)
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

    private var latestPoint: MeetingQualityPoint? {
        points.last
    }

    private var selectedPoint: MeetingQualityPoint? {
        guard let selectedPointId else { return nil }
        return points.first { $0.id == selectedPointId }
    }

    private func annotationEdge(for point: MeetingQualityPoint) -> MeetingQualityAnnotationEdge {
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

    private func annotationPosition(
        for point: MeetingQualityPoint,
        pointPosition: CGPoint,
        plotFrame: CGRect
    ) -> CGPoint {
        var xPosition = pointPosition.x
        let yPosition = max(plotFrame.minY + 22, pointPosition.y - 38)

        switch annotationEdge(for: point) {
        case .leading:
            xPosition += 34
        case .trailing:
            xPosition -= 34
        default:
            break
        }

        return CGPoint(x: xPosition, y: yPosition)
    }

    private func pointSelectionAccessibilityLabel(_ point: MeetingQualityPoint) -> String {
        let score = String(format: "%.1f", point.value)
        let date = point.date.formatted(.dateTime.day().month())
        return "Vis session fra \(date), score \(score) ud af 5"
    }

    private func pointNavigationAccessibilityLabel(_ point: MeetingQualityPoint) -> String {
        let score = String(format: "%.1f", point.value)
        let date = point.date.formatted(.dateTime.day().month())
        return "Åbn session fra \(date), score \(score) ud af 5"
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
