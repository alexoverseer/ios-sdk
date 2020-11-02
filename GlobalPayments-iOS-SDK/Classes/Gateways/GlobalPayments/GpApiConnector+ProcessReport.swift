import Foundation

extension GpApiConnector: ReportingServiceType {

    func processReport<T>(builder: ReportBuilder<T>,
                          completion: ((T?, Error?) -> Void)?) {

        verifyAuthentication { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }

            var reportUrl: String = .empty
            var queryStringParams = [String: String]()
            var method: HTTPMethod = .get

            if let builder = builder as? TransactionReportBuilder<T> {

                if builder.reportType == .transactionDetail,
                   let transactionId = builder.transactionId {
                    reportUrl = Endpoints.transactionsWith(transactionId: transactionId)
                }
                else if builder.reportType == .findTransactions {
                    reportUrl = Endpoints.transactions()

                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    queryStringParams["order_by"] = builder.transactionOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.transactionOrder?.mapped(for: .gpApi)
                    queryStringParams["id"] = builder.transactionId
                    queryStringParams["type"] = builder.searchCriteriaBuilder.paymentType?.mapped(for: .gpApi)
                    queryStringParams["channel"] = builder.searchCriteriaBuilder.channel?.mapped(for: .gpApi)
                    queryStringParams["amount"] = builder.searchCriteriaBuilder.amount?.toNumericCurrencyString()
                    queryStringParams["currency"] = builder.searchCriteriaBuilder.currency
                    queryStringParams["number_first6"] = builder.searchCriteriaBuilder.cardNumberFirstSix
                    queryStringParams["number_last4"] = builder.searchCriteriaBuilder.cardNumberLastFour
                    queryStringParams["token_first6"] = builder.searchCriteriaBuilder.tokenFirstSix
                    queryStringParams["token_last4"] = builder.searchCriteriaBuilder.tokenLastFour
                    queryStringParams["account_name"] = builder.searchCriteriaBuilder.accountName
                    queryStringParams["brand"] = builder.searchCriteriaBuilder.cardBrand
                    queryStringParams["brand_reference"] = builder.searchCriteriaBuilder.brandReference
                    queryStringParams["authcode"] = builder.searchCriteriaBuilder.authCode
                    queryStringParams["reference"] = builder.searchCriteriaBuilder.referenceNumber
                    queryStringParams["status"] = builder.searchCriteriaBuilder.transactionStatus?.mapped(for: .gpApi)
                    queryStringParams["from_time_created"] = (builder.startDate ?? Date()).format("yyyy-MM-dd")
                    if let endDate = builder.endDate {
                        queryStringParams["to_time_created"] = endDate.format("yyyy-MM-dd")
                    }
                    queryStringParams["country"] = builder.searchCriteriaBuilder.country
                    queryStringParams["batch_id"] = builder.searchCriteriaBuilder.batchId
                    queryStringParams["entry_mode"] = builder.searchCriteriaBuilder.paymentEntryMode?.mapped(for: .gpApi)
                    queryStringParams["name"] = builder.searchCriteriaBuilder.name
                }
                else if builder.reportType == .findSettlementTransactions {
                    reportUrl = Endpoints.settlementTransactions()

                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    queryStringParams["order_by"] = builder.transactionOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.transactionOrder?.mapped(for: .gpApi)
                    queryStringParams["number_first6"] = builder.searchCriteriaBuilder.cardNumberFirstSix
                    queryStringParams["number_last4"] = builder.searchCriteriaBuilder.cardNumberLastFour
                    queryStringParams["deposit_status"] = builder.searchCriteriaBuilder.depositStatus?.mapped(for: .gpApi)
                    queryStringParams["account_name"] = self?.dataAccountName
                    queryStringParams["brand"] = builder.searchCriteriaBuilder.brandReference
                    queryStringParams["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
                    queryStringParams["brand_reference"] = builder.searchCriteriaBuilder.brandReference
                    queryStringParams["authcode"] = builder.searchCriteriaBuilder.authCode
                    queryStringParams["reference"] = builder.searchCriteriaBuilder.referenceNumber
                    queryStringParams["status"] = builder.searchCriteriaBuilder.transactionStatus?.mapped(for: .gpApi)
                    queryStringParams["from_time_created"] = (builder.startDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["to_time_created"] = (builder.endDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["deposit_id"] = builder.searchCriteriaBuilder.depositReference
                    queryStringParams["from_deposit_time_created"] = builder.searchCriteriaBuilder.startDepositDate?.format("yyyy-MM-dd")
                    queryStringParams["to_deposit_time_created"] = builder.searchCriteriaBuilder.endDepositDate?.format("yyyy-MM-dd")
                    queryStringParams["from_batch_time_created"] = builder.searchCriteriaBuilder.startBatchDate?.format("yyyy-MM-dd")
                    queryStringParams["to_batch_time_created"] = builder.searchCriteriaBuilder.endBatchDate?.format("yyyy-MM-dd")
                    queryStringParams["system.mid"] = builder.searchCriteriaBuilder.merchantId
                    queryStringParams["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
                }
                else if builder.reportType == .findDeposits {
                    reportUrl = Endpoints.deposits()

                    queryStringParams["account_name"] = self?.dataAccountName
                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    if let status = builder.depositStatus?.mapped(for: .gpApi) {
                        queryStringParams["status"] = status
                    }
                    queryStringParams["order_by"] = builder.depositOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.depositOrder?.mapped(for: .gpApi)
                    queryStringParams["from_time_created"] = (builder.startDate ?? Date()).format("yyyy-MM-dd")
                }
                else if builder.reportType == .depositDetail,
                          let depositId = builder.searchCriteriaBuilder.depositReference {
                    reportUrl = Endpoints.deposit(id: depositId)
                }
                else if builder.reportType == .findDisputes {

                    reportUrl = Endpoints.disputes()

                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    queryStringParams["order_by"] = builder.disputeOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.disputeOrder?.mapped(for: .gpApi)
                    queryStringParams["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
                    queryStringParams["brand"] = builder.searchCriteriaBuilder.cardBrand
                    queryStringParams["status"] = builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi)
                    queryStringParams["stage"] = builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi)
                    queryStringParams["from_stage_time_created"] = (builder.searchCriteriaBuilder.startStageDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["to_stage_time_created"] = (builder.searchCriteriaBuilder.endStageDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["adjustment_funding"] = builder.searchCriteriaBuilder.adjustmentFunding?.mapped(for: .gpApi)
                    if let startAdjustmentDate = builder.searchCriteriaBuilder.startAdjustmentDate {
                        queryStringParams["from_adjustment_time_created"] = startAdjustmentDate.format("yyyy-MM-dd")
                    }
                    if let endAdjustmentDate = builder.searchCriteriaBuilder.endAdjustmentDate {
                        queryStringParams["to_adjustment_time_created"] = endAdjustmentDate.format("yyyy-MM-dd")
                    }
                    queryStringParams["system.mid"] = builder.searchCriteriaBuilder.merchantId
                    queryStringParams["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
                }
                else if builder.reportType == .findSettlementDisputes {
                    reportUrl = Endpoints.settlementDisputes()

                    if let page = builder.page {
                        queryStringParams["page"] = "\(page)"
                    }
                    if let pageSize = builder.pageSize {
                        queryStringParams["page_size"] = "\(pageSize)"
                    }
                    queryStringParams["order_by"] = builder.disputeOrderBy?.mapped(for: .gpApi)
                    queryStringParams["order"] = builder.disputeOrder?.mapped(for: .gpApi)
                    queryStringParams["arn"] = builder.searchCriteriaBuilder.aquirerReferenceNumber
                    queryStringParams["brand"] = builder.searchCriteriaBuilder.cardBrand
                    queryStringParams["STATUS"] = builder.searchCriteriaBuilder.disputeStatus?.mapped(for: .gpApi)
                    queryStringParams["stage"] = builder.searchCriteriaBuilder.disputeStage?.mapped(for: .gpApi)
                    queryStringParams["from_stage_time_created"] = (builder.searchCriteriaBuilder.startStageDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["to_stage_time_created"] = (builder.searchCriteriaBuilder.endStageDate ?? Date()).format("yyyy-MM-dd")
                    queryStringParams["adjustment_funding"] = builder.searchCriteriaBuilder.adjustmentFunding?.mapped(for: .gpApi)
                    if let startAdjustmentDate = builder.searchCriteriaBuilder.startAdjustmentDate {
                        queryStringParams["from_adjustment_time_created"] = startAdjustmentDate.format("yyyy-MM-dd")
                    }
                    if let endAdjustmentDate = builder.searchCriteriaBuilder.endAdjustmentDate {
                        queryStringParams["to_adjustment_time_created"] = endAdjustmentDate.format("yyyy-MM-dd")
                    }
                    queryStringParams["system.mid"] = builder.searchCriteriaBuilder.merchantId
                    queryStringParams["system.hierarchy"] = builder.searchCriteriaBuilder.systemHierarchy
                    queryStringParams["account_name"] = self?.dataAccountName
                }
                else if builder.reportType == .disputeDetail,
                         let disputeId = builder.searchCriteriaBuilder.disputeReference {
                   reportUrl = Endpoints.dispute(id: disputeId)
               }
                else if builder.reportType == .acceptDispute,
                        let disputeId = builder.searchCriteriaBuilder.disputeReference {
                    reportUrl = Endpoints.acceptDispute(id: disputeId)
                    method = .post
                }
                else if builder.reportType == .challangeDispute,
                        let disputeId = builder.searchCriteriaBuilder.disputeReference,
                        let documents = builder.disputeDocuments,
                        let data = try? ["documents": documents].asString() {

                    self?.doTransaction(
                        method: .post,
                        endpoint: Endpoints.challengeDispute(id: disputeId),
                        data: data) { [weak self] response, error in
                        if let error = error {
                            completion?(nil, error)
                            return
                        }
                        guard let response = response else {
                            completion?(nil, error)
                            return
                        }

                        completion?(self?.mapReportResponse(response, builder.reportType), nil)
                        return
                    }
                    return
                }
                else if builder.reportType == .disputeDocument,
                        let disputeId = builder.searchCriteriaBuilder.disputeReference,
                        let documentId = builder.searchCriteriaBuilder.disputeDocumentReference {
                    reportUrl = Endpoints.document(id: documentId, disputeId: disputeId)
                }
            }

            self?.doTransaction(
                method: method,
                endpoint: reportUrl,
                queryStringParams: queryStringParams) { [weak self] response, error in
                if let error = error {
                    completion?(nil, error)
                    return
                }
                guard let response = response else {
                    completion?(nil, error)
                    return
                }

                completion?(self?.mapReportResponse(response, builder.reportType), nil)
            }
        }
    }

    private func mapReportResponse<T>(_ rawResponse: String, _ reportType: ReportType) -> T? {
        var result: Any?
        let json = JsonDoc.parse(rawResponse)

        if reportType == .transactionDetail && TransactionSummary() is T {
            result = mapTransactionSummary(json)
        } else if reportType == .findTransactions && [TransactionSummary]() is T {
            if let transactions: [JsonDoc] = json?.getValue(key: "transactions") {
                let mapped = transactions.map { mapTransactionSummary($0) }
                result = mapped
            }
        } else if reportType == .findSettlementTransactions && [TransactionSummary]() is T {
            if let transactions: [JsonDoc] = json?.getValue(key: "transactions") {
                let mapped = transactions.map { mapTransactionSummary($0) }
                result = mapped
            }
        } else if reportType == .depositDetail && DepositSummary() is T {
            result = mapDepositSummary(json)
        } else if reportType == .findDeposits && [DepositSummary]() is T {
            if let deposits: [JsonDoc] = json?.getValue(key: "deposits") {
                let mapped = deposits.map { mapDepositSummary($0) }
                result = mapped
            }
        } else if reportType == .disputeDetail && DisputeSummary() is T {
            result = mapDisputeSummary(json)
        } else if (reportType == .findDisputes || reportType == .findSettlementDisputes) && [DisputeSummary]() is T {
            if let disputes: [JsonDoc] = json?.getValue(key: "disputes") {
                let mapped = disputes.map { mapDisputeSummary($0) }
                result = mapped
            }
        } else if reportType == .acceptDispute || reportType == .challangeDispute {
            result = mapDisputeAction(json)
        } else if reportType == .disputeDocument {
            result = mapDocumentMetadata(json)
        }

        return result as? T
    }

    private func mapTransactionSummary(_ doc: JsonDoc?) -> TransactionSummary {
        let paymentMethod: JsonDoc? = doc?.get(valueFor: "payment_method")
        let card: JsonDoc? = paymentMethod?.get(valueFor: "card")

        let summary = TransactionSummary()
        //TODO: Map all transaction properties
        summary.transactionId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.transactionDate = timeCreated?.format()
        summary.transactionStatus = TransactionStatus(value: doc?.getValue(key: "status"))
        summary.transactionType = doc?.getValue(key: "type")
        summary.channel = doc?.getValue(key: "channel")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        summary.currency = doc?.getValue(key: "currency")
        summary.referenceNumber = doc?.getValue(key: "reference")
        summary.clientTransactionId = doc?.getValue(key: "reference")
        // ?? = doc.getValue(key: "time_created_reference")
        summary.batchSequenceNumber = doc?.getValue(key: "batch_id")
        summary.country = doc?.getValue(key: "country")
        // ?? = doc.getValue(key: "action_create_id")
        summary.originalTransactionId = doc?.getValue(key: "parent_resource_id")

        summary.gatewayResponseMessage = paymentMethod?.getValue(key: "message")
        summary.entryMode = paymentMethod?.getValue(key: "entry_mode")
        //?? = paymentMethod?.getValue(key: "name")

        summary.cardType = card?.getValue(key: "brand")
        summary.authCode = card?.getValue(key: "authcode")
        summary.brandReference = card?.getValue(key: "brand_reference")
        summary.aquirerReferenceNumber = card?.getValue(key: "arn")
        summary.maskedCardNumber = card?.getValue(key: "masked_number_first6last4")

        summary.depositReference = doc?.getValue(key: "deposit_id")
        let depositTimeCreated: String? = doc?.getValue(key: "deposit_time_created")
        summary.depositDate = depositTimeCreated?.format("YYYY-MM-DD")
        summary.depositStatus = DepositStatus(value: doc?.getValue(key: "deposit_status"))

        return summary
    }

    private func mapDepositSummary(_ doc: JsonDoc?) -> DepositSummary {
        let summary = DepositSummary()
        summary.depositId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.depositDate = timeCreated?.format("yyyy-MM-dd")
        summary.status = doc?.getValue(key: "status")
        summary.type = doc?.getValue(key: "funding_type")
        summary.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        summary.currency = doc?.getValue(key: "currency")

        summary.merchantNumber = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.merchantName = doc?.get(valueFor: "system")?.getValue(key: "name")
        summary.merchantDbaName = doc?.get(valueFor: "system")?.getValue(key: "dba")

        summary.salesTotalCount = doc?.get(valueFor: "sales")?.getValue(key: "count")
        summary.amount = NSDecimalNumber(string: doc?.get(valueFor: "sales")?.getValue(key: "amount")).amount

        summary.refundsTotalCount = doc?.get(valueFor: "refunds")?.getValue(key: "count")
        summary.refundsTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "refunds")?.getValue(key: "amount")).amount

        summary.chargebackTotalCount = doc?.get(valueFor: "disputes")?.get(valueFor: "chargebacks")?.getValue(key: "count")
        summary.chargebackTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "disputes")?.get(valueFor: "chargebacks")?.getValue(key: "amount")).amount

        summary.adjustmentTotalCount = doc?.get(valueFor: "disputes")?.get(valueFor: "reversals")?.getValue(key: "count")
        summary.adjustmentTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "disputes")?.get(valueFor: "reversals")?.getValue(key: "amount")).amount

        summary.feesTotalAmount = NSDecimalNumber(string: doc?.get(valueFor: "fees")?.getValue(key: "amount")).amount

        return summary
    }

    private func mapDisputeSummary(_ doc: JsonDoc?) -> DisputeSummary {
        let summary = DisputeSummary()
        // TODO: map all available fields
        summary.caseId = doc?.getValue(key: "id")
        let timeCreated: String? = doc?.getValue(key: "time_created")
        summary.caseIdTime = timeCreated?.format()
        summary.caseStatus = doc?.getValue(key: "status")
        summary.caseStage = DisputeStage(value: doc?.getValue(key: "stage"))
        //stage
        summary.caseAmount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        summary.caseCurrency = doc?.getValue(key: "currency")
        summary.caseMerchantId = doc?.get(valueFor: "system")?.getValue(key: "mid")
        summary.merchantHierarchy = doc?.get(valueFor: "system")?.getValue(key: "hierarchy")
        summary.transactionMaskedCardNumber = doc?.get(valueFor: "payment_method")?.get(valueFor: "card")?.getValue(key: "number")
        summary.transactionARN = doc?.get(valueFor: "payment_method")?.get(valueFor: "card")?.getValue(key: "arn")
        summary.transactionCardType = doc?.get(valueFor: "payment_method")?.get(valueFor: "card")?.getValue(key: "brand")
        //reason_code
        summary.reason = doc?.getValue(key: "reason_description")
        let timeToRespondBy: String? = doc?.getValue(key: "time_to_respond_by")
        summary.respondByDate = timeToRespondBy?.format()
        if let documents: [JsonDoc] = doc?.getValue(key: "documents"), !documents.isEmpty {
            summary.documents = documents.compactMap {
                guard let id: String = $0.getValue(key: "id"),
                      let type = DocumentType(value: $0.getValue(key: "type")) else { return nil }
                return DisputeDocument(id: id, type: type)
            }
        }

        summary.adjustmentFunding = AdjustmentFunding(value: doc?.getValue(key: "last_adjustment_funding"))
        summary.adjustmentAmount = NSDecimalNumber(string: doc?.getValue(key: "last_adjustment_amount")).amount
        summary.adjustmentCurrency = doc?.getValue(key: "last_adjustment_currency")

        return summary
    }

    private func mapDisputeAction(_ doc: JsonDoc?) -> DisputeAction {
        let action = DisputeAction()
        action.reference = doc?.getValue(key: "id")
        action.status = DisputeStatus(value: doc?.getValue(key: "status"))
        action.stage = DisputeStage(value: doc?.getValue(key: "stage"))
        action.amount = NSDecimalNumber(string: doc?.getValue(key: "amount")).amount
        action.currency = doc?.getValue(key: "currency")
        action.reasonCode = doc?.getValue(key: "reason_code")
        action.reasonDescription = doc?.getValue(key: "reason_description")
        action.result = DisputeResult(value: doc?.getValue(key: "result"))
        if let documents: [JsonDoc?] = doc?.getValue(key: "documents") {
            action.documents = documents.compactMap { $0?.getValue(key: "id") }
        }

        return action
    }

    private func mapDocumentMetadata(_ doc: JsonDoc?) -> DocumentMetadata? {
        guard let id: String = doc?.getValue(key: "id"),
              let b64Content: String = doc?.getValue(key: "b64_content"),
              let convertedData = Data(base64Encoded: b64Content) else {
            return nil
        }

        return DocumentMetadata(id: id, b64Content: convertedData)
    }
}
