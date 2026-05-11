import Domain
import OpenAPI

public extension ActivityTrend {
    init(_ dto: Components.Schemas.ActivityTrendDto) {
        self.init(
            direction: .init(dto.direction),
            indicator: .init(dto.indicator),
            metric: .init(dto.metric),
            latestValue: dto.latestValue,
            previousValue: dto.previousValue,
            delta: dto.delta,
            comparedSessionCount: Int(dto.comparedEventCount)
        )
    }
}

public extension ActivityTrend.Direction {
    init(_ payload: Components.Schemas.ActivityTrendDto.DirectionPayload) {
        switch payload {
        case .improving:
            self = .improving
        case .stable:
            self = .stable
        case .declining:
            self = .declining
        case .insufficientData:
            self = .insufficientData
        }
    }
}

public extension ActivityTrend.Indicator {
    init(_ payload: Components.Schemas.ActivityTrendDto.IndicatorPayload) {
        switch payload {
        case .positive:
            self = .positive
        case .neutral:
            self = .neutral
        case .negative:
            self = .negative
        }
    }
}

public extension ActivityTrend.Metric {
    init(_ payload: Components.Schemas.ActivityTrendDto.MetricPayload) {
        switch payload {
        case .averageRating:
            self = .averageRating
        }
    }
}
