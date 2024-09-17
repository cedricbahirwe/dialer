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
        Analytics.logEvent(
            name.stringValue,
            parameters: completeParameters
        )
    }
    
    func logEvent(name: AnalyticsEventType) {
        logEvent(name: name, parameters: nil)
    }

    func logTransaction(transaction: Transaction) {
        var params: [EventParameterKey: Any] = [
            .transId : transaction.id,
            .transAmount : transaction.doubleAmount,
            .transType : transaction.type.rawValue,
            .transCode : transaction.fullCode,
            .transTime : Date.now.formatted()
        ]

        if let device = DialerStorage.shared.getSavedDevice() {
            params[.devHash] = device.deviceHash
        }

        let objectParams = Dictionary(uniqueKeysWithValues: params.map { key, value in (key.rawValue, value) })

        logEvent(
            name: AppAnalyticsEventType.transaction,
            parameters: objectParams
        )

        recordTransaction(.momo(transaction))
    }

    func logTransaction(record: RecordDetails) {
        recordTransaction(record)
    }

    func logMerchantSelection(_ merchant: Merchant) {
        guard let ownerId = merchant.ownerId else { return }
        logEvent(
            name: AppAnalyticsEventType.merchantCodeSelected,
            parameters: [
                "merchant_code": merchant.code,
                "owner_id": ownerId
            ]
        )
    }
    
    func logMerchantScan(_ merchantCode: String) {
        logEvent(
            name: AppAnalyticsEventType.merchantCodeScanned,
            parameters: [ "merchant_code": merchantCode]
        )
    }

    func logSignIn(account: DeviceAccount) {
        logEvent(
            name: AppAnalyticsEventType.logIn,
            parameters: account.toDictionary()
        )
    }

    func logError(error: Error) {
        Log.add(
            "Error: ",
            type: .error,
            error.localizedDescription
        )
    }
}
