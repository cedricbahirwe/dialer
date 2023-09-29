//
//  FirebaseTracker+Extensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation
import FirebaseAnalytics

extension FirebaseTracker: TrackerProtocol {
    func logEvent(name: AnalyticsEventType, parameters: [String : Any]?) {
        var completeParameters: [String : Any] = parameters ?? [:]
        completeParameters[AnalyticsParameterExtendSession] = true
        Analytics.logEvent(name.stringValue, parameters: completeParameters)
    }
    
    func logEvent(name: AnalyticsEventType) {
        logEvent(name: name, parameters: nil)
    }

    func logTransaction(transaction: Transaction) {
        let params: [EventParameterKey: Any] = [
            .transId : transaction.id,
            .transAmount : transaction.doubleAmount,
            .transType : transaction.type.rawValue,
            .transCode : transaction.fullCode,
            .transTime : Date.now.formatted()
        ]

        let objectParams = Dictionary(uniqueKeysWithValues: params.map { key, value in (key.rawValue, value) })

        logEvent(name: AppAnalyticsEventType.transaction,
                 parameters: objectParams)
    }

    func logTransaction(transaction: Transaction, user: DeviceAccount) {
        let params: [EventParameterKey: Any] = [
            .transId : transaction.id,
            .transAmount : transaction.id,
            .transType : transaction.type.rawValue,
            .transCode : transaction.fullCode,
            .transTime : Date.now.formatted(),
            .devHash: user.deviceHash
        ]

        let objectParams = Dictionary(uniqueKeysWithValues: params.map { key, value in (key.rawValue, value) })

        logEvent(name: AppAnalyticsEventType.transaction,
                 parameters: objectParams)
    }
    
    func logMerchantSelection(_ merchant: Merchant) {
        guard let ownerId = merchant.ownerId else { return }
        logEvent(name: AppAnalyticsEventType.merchantCodeSelected,
                 parameters: [
                    "merchant_code": merchant.code,
                    "owner_id": ownerId
                 ])
    }
    
    func logMerchantScan(_ merchantCode: String) {
        logEvent(name: AppAnalyticsEventType.merchantCodeScanned,
                 parameters: [ "merchant_code": merchantCode])
    }

    func logSignIn(account: DeviceAccount) {
        logEvent(name: AppAnalyticsEventType.logIn,
                 parameters: account.toDictionary())
    }

    func logError(error: Error) {
        Log.add("Error: ", type: .error, error.localizedDescription)
    }
}
