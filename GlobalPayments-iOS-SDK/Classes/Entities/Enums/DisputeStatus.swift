import Foundation

public enum DisputeStatus: String, Mappable {
    case underReview = "UNDER_REVIEW"
    case withMerchant = "WITH_MERCHANT"
    case closed = "CLOSED"

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue
        default:
            return nil
        }
    }
}
