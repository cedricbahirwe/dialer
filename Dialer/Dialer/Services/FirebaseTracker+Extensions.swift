//
//  FirebaseTracker+Extensions.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/03/2023.
//

import Foundation


extension FirebaseTracker: TrackerProtocol {
    func logEvent(name: AnalyticsEventType, parameters: [String : Any]?) {

    }

    func logTransaction(transaction: Transaction) {

    }

    func logTransaction(transaction: Transaction, user: DeviceAccount) {

    }

    func logSignIn(account: DeviceAccount) {

    }

    func logError(error: Error) {
        
    }

}
