import Foundation

public enum IntervalToExpire: String, Mappable {
    case week = "WEEK"
    case day = "DAY"
    case twelveHours = "12_HOURS"
    case sixHours = "6_HOURS"
    case threeHours = "3_HOURS"
    case oneHour = "1_HOUR"
    case thirtyMinutes = "30_MINUTES"
    case tenMinutes = "10_MINUTES"
    case fiveMinutes = "5_MINUTES"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}