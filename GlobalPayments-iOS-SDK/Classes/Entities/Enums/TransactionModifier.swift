import Foundation

@objc public enum TransactionModifier: Int {
    case none
    case incremental
    case additional
    case offline
    case levelII
    case fraudDecline
    case chipDecline
    case cashBack
    case voucher
    case recurring
    case hostedRequest
    case encryptedMobile
    case secure3D
    case alternativePaymentMethod
}
