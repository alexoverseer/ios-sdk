import Foundation

/// Used to follow up transactions for the supported payment method types.
@objcMembers public class ManagementBuilder: TransactionBuilder {
    /// Request amount
    var amount: Decimal?
    /// Request authorization amount
    var authAmount: Decimal?
    var authorizationCode: String? {
        guard let paymentMethod = paymentMethod as? TransactionReference else {
            return nil
        }
        return paymentMethod.authCode
    }
    var clientTransactionId: String? {
        guard let paymentMethod = paymentMethod as? TransactionReference else {
            return nil
        }
        return paymentMethod.clientTransactionId
    }
    /// Request currency
    var currency: String?
    var customerId: String?
    var managementBuilderDescription: String?
    /// Request gratuity
    var gratuity: Decimal?
    /// Request purchase order number
    var poNumber: String?
    var reasonCode: String?
    /// Request tax amount
    var taxAmount: Decimal?
    var taxType: TaxType?
    /// Previous request's transaction reference
    var alternativePaymentType: String?
    var payerAuthenticationResponse: String?
    var multiCapturePaymentCount: Int?
    var multiCaptureSequence: Int?
    var invoiceNumber: String?
    var lodgingData: LodgingData?

    /// Sets the current transaction's amount.
    /// - Parameter amount: The amount
    /// - Returns: ManagementBuilder
    public func withAmount(_ amount: Decimal?) -> ManagementBuilder {
        self.amount = amount
        return self
    }

    /// Sets the current transaction's authorized amount; where applicable.
    /// - Parameter authAmount: The authorized amount
    /// - Returns: ManagementBuilder
    public func withAuthAmount(_ authAmount: Decimal?) -> ManagementBuilder {
        self.authAmount = authAmount
        return self
    }

    /// Sets the Multicapture value as true/false.
    /// - Parameters:
    /// - Returns: ManagementBuilder
    public func withMultiCapture(sequence: Int = 1, paymentCount: Int = 1) -> ManagementBuilder {
        self.multiCapture = true
        self.multiCaptureSequence = sequence
        self.multiCapturePaymentCount = paymentCount
        return self
    }

    /// Sets the currency.
    /// The formatting for the supplied value will currently depend on the configured gateway's requirements.
    /// - Parameter currency: The currency
    /// - Returns: ManagementBuilder
    public func withCurrency(_ currency: String?) -> ManagementBuilder {
        self.currency = currency
        return self
    }

    /// Sets the customer ID; where applicable.
    /// - Parameter customerId: The customer ID
    /// - Returns: ManagementBuilder
    public func withCustomerId(_ customerId: String) -> ManagementBuilder {
        self.customerId = customerId
        return self
    }

    /// Sets the transaction's description.
    /// - Parameter description: This value is not guaranteed to be sent in the authorization or settlement process.
    /// - Returns: ManagementBuilder
    public func withDescription(_ description: String) -> ManagementBuilder {
        self.managementBuilderDescription = description
        return self
    }

    /// Sets the gratuity amount; where applicable.
    /// - Parameter gratuity: This value is information only and does not affect the authorization amount.
    /// - Returns: ManagementBuilder
    public func withGratuity(_ gratuity: Decimal?) -> ManagementBuilder {
        self.gratuity = gratuity
        return self
    }

    /// Sets the invoice number; where applicable.
    /// - Parameter invoiceNumber: The invoice number
    /// - Returns: ManagementnBuilder
    public func withInvoiceNumber(_ invoiceNumber: String) -> ManagementBuilder {
        self.invoiceNumber = invoiceNumber
        return self
    }

    public func withPayerAuthenticationResponse(_ response: String) -> ManagementBuilder {
        self.payerAuthenticationResponse = response
        return self
    }

    func withPaymentMethod(_ paymentMethod: PaymentMethod) -> ManagementBuilder {
        self.paymentMethod = paymentMethod
        return self
    }

    func withModifier(_ modifier: TransactionModifier) -> ManagementBuilder {
        self.transactionModifier = modifier
        return self
    }

    public override func execute() -> Any? {
        _  = super.execute()
        return ServicesContainer.shared
            .getClient()?
            .manageTransaction(self)
    }

    /// Lodging data information for Portico implementation
    /// - Parameter lodgingData: The lodging data
    /// - Returns: ManagementBuilder
    public func withLodgingData(_ lodgingData: LodgingData) -> ManagementBuilder {
        self.lodgingData = lodgingData
        return self
    }

    public override func setupValidations() {

        validations.of(transactionType: [.capture, .edit, .hold, .release])
            .check(propertyName: "transactionId")?.isNotNil()

        validations.of(transactionType: .refund)
            .when(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()

        validations.of(transactionType: .verifySignature)
            .check(propertyName: "payerAuthenticationResponse")?.isNotNil()?
            .check(propertyName: "amount")?.isNotNil()?
            .check(propertyName: "currency")?.isNotNil()?
            .check(propertyName: "orderId")?.isNotNil()

        validations.of(transactionType: [.tokenDelete, .tokenUpdate])
            .check(propertyName: "paymentMethod")?.isNotNil()?
            .check(propertyName: "paymentMethod")?.conformsTo(protocol: Tokenizable.self)

        validations.of(transactionType: .tokenUpdate)
            .check(propertyName: "paymentMethod")?.isInstanceOf(type: CreditCardData.self)

        validations.of(transactionType: [.capture, .edit, .hold, .release, .tokenUpdate, .tokenDelete, .verifySignature, .refund])
            .check(propertyName: "voidReason")?.isNotNil()
    }
}
