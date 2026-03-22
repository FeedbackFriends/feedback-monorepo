import SwiftUI

// MARK: - Models

struct Focus: Identifiable, Hashable {
    let id: String
    let title: String
    let color: FocusColor
    let createdAt: Date
}

struct Session2: Identifiable, Hashable {
    let id: String
    let focusId: String
    let date: Date
    let averageScore: Double
    let summary: String
}

struct FeedbackEntry: Identifiable, Hashable {
    let id: String
    let sessionId: String
    let author: String
    let score: Int
    let comment: String
}

enum FocusColor: String, CaseIterable, Codable {
    case green
    case yellow
    case red

    var color: Color {
        switch self {
        case .green: return .green
        case .yellow: return .yellow
        case .red: return .red
        }
    }
}

// MARK: - Mock Store

@MainActor
final class GrowthViewModel: ObservableObject {
    @Published var focuses: [Focus] = []
    @Published var sessions: [Session2] = []
    @Published var feedback: [FeedbackEntry] = []

    init() {
        loadMockData()
    }

    func loadMockData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        focuses = [
            Focus(id: "focus_1", title: "Leadership in team meetings", color: .green, createdAt: formatter.date(from: "2026-03-01") ?? .now),
            Focus(id: "focus_2", title: "Workshop facilitation", color: .yellow, createdAt: formatter.date(from: "2026-03-03") ?? .now),
            Focus(id: "focus_3", title: "Client presentations", color: .red, createdAt: formatter.date(from: "2026-02-20") ?? .now)
        ]

        sessions = [
            Session2(id: "s1", focusId: "focus_1", date: formatter.date(from: "2026-03-16") ?? .now, averageScore: 4.2, summary: "Clear improvement and better energy."),
            Session2(id: "s2", focusId: "focus_1", date: formatter.date(from: "2026-03-10") ?? .now, averageScore: 3.8, summary: "Good foundation, involve quieter people more."),
            Session2(id: "s3", focusId: "focus_1", date: formatter.date(from: "2026-03-03") ?? .now, averageScore: 3.4, summary: "Needs more clarity and stronger wrap-up."),

            Session2(id: "s4", focusId: "focus_2", date: formatter.date(from: "2026-03-12") ?? .now, averageScore: 3.5, summary: "Engaging, but timing could improve."),
            Session2(id: "s5", focusId: "focus_2", date: formatter.date(from: "2026-03-05") ?? .now, averageScore: 3.6, summary: "Stable overall. Good pace."),
            
            Session2(id: "s6", focusId: "focus_3", date: formatter.date(from: "2026-02-28") ?? .now, averageScore: 2.9, summary: "Story needs tightening."),
            Session2(id: "s7", focusId: "focus_3", date: formatter.date(from: "2026-02-18") ?? .now, averageScore: 3.2, summary: "Slides were good, delivery less confident.")
        ]

        feedback = [
            FeedbackEntry(id: "f1", sessionId: "s1", author: "Anna", score: 4, comment: "Much clearer this time."),
            FeedbackEntry(id: "f2", sessionId: "s1", author: "Mikkel", score: 5, comment: "Strong presence and good energy."),
            FeedbackEntry(id: "f3", sessionId: "s2", author: "Sara", score: 4, comment: "Good meeting flow."),
            FeedbackEntry(id: "f4", sessionId: "s6", author: "Jonas", score: 3, comment: "Needs a sharper opening.")
        ]
    }

    func sessions(for focus: Focus) -> [Session2] {
        sessions
            .filter { $0.focusId == focus.id }
            .sorted { $0.date > $1.date }
    }

    func feedback(for session: Session2) -> [FeedbackEntry] {
        feedback.filter { $0.sessionId == session.id }
    }

    func latestSession(for focus: Focus) -> Session2? {
        sessions(for: focus).first
    }

    func trend(for focus: Focus) -> Trend2 {
        let scores = sessions(for: focus).map(\.averageScore)
        guard scores.count >= 2 else { return .stable }
        let latest = scores[0]
        let previous = scores[1]

        if latest > previous + 0.1 { return .improving }
        if latest < previous - 0.1 { return .declining }
        return .stable
    }

    func addFocus(title: String, color: FocusColor) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newFocus = Focus(
            id: UUID().uuidString,
            title: trimmed,
            color: color,
            createdAt: .now
        )
        focuses.insert(newFocus, at: 0)
    }

    func startSession(for focus: Focus) {
        let newSession = Session2(
            id: UUID().uuidString,
            focusId: focus.id,
            date: .now,
            averageScore: 0.0,
            summary: "New session started"
        )
        sessions.insert(newSession, at: 0)
    }
}

enum Trend2 {
    case improving
    case stable
    case declining

    var title: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Needs Attention"
        }
    }

    var symbolName: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }

    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .orange
        case .declining: return .red
        }
    }
}

// MARK: - App Root

struct ContentView: View {
    @StateObject private var viewModel = GrowthViewModel()

    var body: some View {
        TabView {
            GrowView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Activities", systemImage: "target")
                }
        }
    }
}

// MARK: - Grow Overview

struct GrowView: View {
    @EnvironmentObject private var viewModel: GrowthViewModel
    @State private var showCreateFocus = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    createCTA

                    ForEach(viewModel.focuses) { focus in
                        NavigationLink(value: focus) {
                            FocusCardView(focus: focus)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Activities")
            .navigationDestination(for: Focus.self) { focus in
                FocusDetailView(focus: focus)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateFocus = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateFocus) {
                CreateFocusView()
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var createCTA: some View {
        Button {
            showCreateFocus = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("What do you want feedback on?")
                        .font(.headline)

                    Text("Create something to get feedback after your meetings, workshops, or sessions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Focus Card

struct FocusCardView: View {
    @EnvironmentObject private var viewModel: GrowthViewModel
    let focus: Focus

    var body: some View {
        let sessions = viewModel.sessions(for: focus)
        let latest = sessions.first
        let trend = viewModel.trend(for: focus)

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(focus.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Label(trend.title, systemImage: trend.symbolName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(trend.color)

                        if let latest {
                            Text("• Last: \(latest.date, style: .relative)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Circle()
                    .fill(focus.color.color)
                    .frame(width: 10, height: 10)
            }

//            MiniTrendView(values: sessions.map(\.averageScore).reversed())

            if let latest {
                Text("\(latest.averageScore, specifier: "%.1f") avg")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                Text("No sessions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Focus Detail

struct FocusDetailView: View {
    @EnvironmentObject private var viewModel: GrowthViewModel
    let focus: Focus

    var body: some View {
        let sessions = viewModel.sessions(for: focus)
        let trend = viewModel.trend(for: focus)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                growthHeader(trend: trend, sessions: sessions)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Progress")
                        .font(.headline)

                    DetailTrendView(values: sessions.map(\.averageScore).reversed())
                }

                Button {
                    viewModel.startSession(for: focus)
                } label: {
                    Label("Start New Session", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Sessions")
                        .font(.headline)

                    ForEach(sessions) { session in
                        SessionCardView(session: session)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(focus.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func growthHeader(trend: Trend2, sessions: [Session2]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(trend.title, systemImage: trend.symbolName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(trend.color)

                Spacer()
            }

            if sessions.count >= 2 {
                let delta = sessions[0].averageScore - sessions[1].averageScore
                Text("\(delta >= 0 ? "+" : "")\(delta, specifier: "%.1f") vs last session")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Track sessions over time to see growth trends.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Session Card

struct SessionCardView: View {
    @EnvironmentObject private var viewModel: GrowthViewModel
    let session: Session2

    var body: some View {
        let feedback = viewModel.feedback(for: session)

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(session.date, format: .dateTime.day().month(.abbreviated).year())
                    .font(.headline)

                Spacer()

                if session.averageScore > 0 {
                    Text(session.averageScore, format: .number.precision(.fractionLength(1)))
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.quaternary, in: Capsule())
                }
            }

            Text(session.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !feedback.isEmpty {
                Divider()

                ForEach(feedback.prefix(2)) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.author)
                                .font(.caption.weight(.semibold))
                            Spacer()
                            Text("\(item.score)/5")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("“\(item.comment)”")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Simple Trend Views

//struct MiniTrendView: View {
//    let values: [Double]
//
//    var body: some View {
//        GeometryReader { geo in
//            let points = normalizedPoints(in: geo.size)
//
//            Path { path in
//                guard let first = points.first else { return }
//                path.move(to: first)
//
//                for point in points.dropFirst() {
//                    path.addLine(to: point)
//                }
//            }
//            .stroke(.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//        }
//        .frame(height: 32)
//    }
//
//    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
//        guard !values.isEmpty else { return [] }
//
//        let minValue = values.min() ?? 0
//        let maxValue = values.max() ?? 1
//        let range = max(maxValue - minValue, 0.1)
//
//        return values.enumerated().map { index, value in
//            let x = values.count == 1 ? size.width / 2 : (CGFloat(index) / CGFloat(values.count - 1)) * size.width
//            let normalizedY = (value - minValue) / range
//            let y = size.height - (CGFloat(normalizedY) * size.height)
//            return CGPoint(x: x, y: y)
//        }
//    }
//}

struct MiniTrendView: View {
    let values: [Double]
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            let points = normalizedPoints(in: geo.size)

            ZStack {
                // Area fill
                areaPath(points: points, size: geo.size)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Glow
                linePath(points)
                    .stroke(.blue.opacity(0.3), lineWidth: 6)
                    .blur(radius: 4)

                // Main line
                linePath(points)
                    .trim(from: 0, to: animate ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )

                // Last point
                if let last = points.last {
                    Circle()
                        .fill(.blue)
                        .frame(width: 6, height: 6)
                        .position(last)
                }
            }
            .onAppear { animate = true }
        }
        .frame(height: 40)
    }

    private func linePath(_ points: [CGPoint]) -> Path {
        Path { path in
            guard points.count > 1 else { return }

            path.move(to: points[0])

            for i in 1..<points.count {
                let mid = CGPoint(
                    x: (points[i].x + points[i - 1].x) / 2,
                    y: (points[i].y + points[i - 1].y) / 2
                )

                path.addQuadCurve(to: mid, control: points[i - 1])
                path.addQuadCurve(to: points[i], control: points[i])
            }
        }
    }

    private func areaPath(points: [CGPoint], size: CGSize) -> Path {
        Path { path in
            guard let first = points.first else { return }

            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }

            path.addLine(to: CGPoint(x: points.last!.x, y: size.height))
            path.addLine(to: CGPoint(x: points.first!.x, y: size.height))
            path.closeSubpath()
        }
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard !values.isEmpty else { return [] }

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let range = max(maxValue - minValue, 0.1)

        return values.enumerated().map { index, value in
            let x = values.count == 1
                ? size.width / 2
                : (CGFloat(index) / CGFloat(values.count - 1)) * size.width

            let normalizedY = (value - minValue) / range
            let y = size.height - (CGFloat(normalizedY) * size.height)

            return CGPoint(x: x, y: y)
        }
    }
}

struct DetailTrendView: View {
    let values: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geo in
                let points = normalizedPoints(in: geo.size)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))

                    Path { path in
                        guard let first = points.first else { return }
                        path.move(to: first)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        Circle()
                            .fill(.background)
                            .frame(width: 10, height: 10)
                            .overlay {
                                Circle().stroke(.primary, lineWidth: 2)
                            }
                            .position(point)
                    }
                }
            }
            .frame(height: 180)

            HStack {
                ForEach(values.indices, id: \.self) { index in
                    Text(values[index], format: .number.precision(.fractionLength(1)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if index < values.count - 1 { Spacer() }
                }
            }
        }
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard !values.isEmpty else { return [] }

        let padding: CGFloat = 20
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let range = max(maxValue - minValue, 0.1)

        return values.enumerated().map { index, value in
            let usableWidth = size.width - (padding * 2)
            let usableHeight = size.height - (padding * 2)

            let x = values.count == 1
                ? size.width / 2
                : padding + (CGFloat(index) / CGFloat(values.count - 1)) * usableWidth

            let normalizedY = (value - minValue) / range
            let y = padding + usableHeight - (CGFloat(normalizedY) * usableHeight)

            return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
