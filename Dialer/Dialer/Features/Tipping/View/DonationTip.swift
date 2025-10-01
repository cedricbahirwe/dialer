//
//  DonationTip.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//
import SwiftUI
import TipKit

@available(iOS 17.0, *)
struct DonationTip: Tip {
    @Parameter
    static var isShown: Bool = false

    var title: Text {
        Text("Support Dialer with a Tip")
    }

    var message: Text? {
        Text("Go to Settings > Support Us.")
    }
    var image: Image? {
        Image(systemName: "hands.sparkles.fill").resizable()
    }

    var rules: [Rule] {
        #Rule(DonationTip.$isShown) {
            $0 == true
        }
    }

    var actions: [Action] {
        Action(id: "donate", title: "Leave a Tip")
    }
}
