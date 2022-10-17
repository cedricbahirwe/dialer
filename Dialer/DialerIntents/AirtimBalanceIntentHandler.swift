//
//  AirtimBalanceIntentHandler.swift
//  DialerIntents
//
//  Created by Cédric Bahirwe on 17/10/2022.
//

import Foundation
import Intents

final class AirtimBalanceIntentHandler: NSObject, BalanceIntentHandling {

    func handle(intent: BalanceIntent, completion: @escaping (BalanceIntentResponse) -> Void) {
        completion(.success(balance: 12.300)) // TODO: Load correct value
    }

}
