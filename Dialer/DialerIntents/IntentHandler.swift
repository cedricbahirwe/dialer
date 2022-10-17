//
//  IntentHandler.swift
//  DialerIntents
//
//  Created by Cédric Bahirwe on 17/10/2022.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any? {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        guard intent is BalanceIntent else { return .none }

        return AirtimBalanceIntentHandler()
    }
    
}
