//
//  BuyAirtimeIntent.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/01/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation
import AppIntents

@available(iOS 18.0, *)
struct BuyAirtimeIntent: AppIntent {
    static let title: LocalizedStringResource = "Buy airtime"

    @Parameter(
        title: "airtime amount",
        inclusiveRange: (100, 10_000),
        requestValueDialog: .init("How much airtime do you want?")
    )
    var amount: Int

    func perform() async throws -> some IntentResult & OpensIntent {
        let airtimTransaction = AirtimeTransaction(amount: amount)

        if let telUrl = try? airtimTransaction.getUSSDURL() {
            let openURLIntent = OpenURLIntent(telUrl)
            return .result(opensIntent: openURLIntent)
        } else {
            throw DialingError.invalidUSSD
        }
    }
}

@available(iOS 18.0, *)
struct DialerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: BuyAirtimeIntent(),
            phrases: [
                "Airtime",
                "Get quick airtime",
                "Buy \(.applicationName) airtime",
                "Momo airtime",
                "Get airtime",
                "Buy airtime on \(.applicationName)",
                "Buy airtime with \(.applicationName)",
                "\(.applicationName) airtime"
            ],
            shortTitle: "Buy airtime",
            systemImageName: "simcard"
        )
    }
}

//
//struct DialerShortcutss: AppShortcutsProvider {
//    static var appShortcuts: [AppShortcut] {
//        var shortcuts: [AppShortcut] = []
//
////        if #available(iOS 18.0, *) {
//            print("We went here")
//            let airtimeShortcut = AppShortcut(
//                intent: BuyAirtimeIntent(),
//                phrases: [
//                    "Buy airtime",
//                    "Buy \(.applicationName) airtime",
//                    "Get airtime",
//                    "Buy airtime on \(.applicationName)",
//                    "Buy airtime with \(.applicationName)"
//                ],
//                shortTitle: "Buy airtime",
//                systemImageName: "simcard"
//            )
//            shortcuts.append(airtimeShortcut)
////        }
//
//        return shortcuts
//    }
//}
