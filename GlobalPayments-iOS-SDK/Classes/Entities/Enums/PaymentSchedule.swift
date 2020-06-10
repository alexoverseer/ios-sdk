import Foundation

/// Indicates when in the month a recurring schedule should run.
@objc public enum PaymentSchedule: Int {
    /// Indicates a specified date.
    case dynamic
    /// Indicates the first of the month.
    case firstDayOfTheMonth
    /// Indicates the last of the month.
    case lastDayOfTheMonth
}
