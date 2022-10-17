//
//  AppIntent.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 17/10/2022.
//

import Foundation
import Intents

final class AppIntent {

    class func allowSiri() {
        INPreferences.requestSiriAuthorization { status in
            switch status {
            case .notDetermined,
                    .restricted,
                    .denied:
                print("Siri unauthorized")
            case .authorized:
                print("Siri authorized")
            @unknown default:
                break;
            }
        }
    }

    class func balance() {
        let intent = BalanceIntent()
        intent.suggestedInvocationPhrase = "Get Airtime Balance"

        let interaction = INInteraction(intent: intent, response: nil)

        interaction.donate { error in
            if let error = error as NSError? {
                print("Interaction donation failed: \(error.localizedDescription)")
            } else {
                print("Successfully dontated interaction.")
            }
        }
    }
}
