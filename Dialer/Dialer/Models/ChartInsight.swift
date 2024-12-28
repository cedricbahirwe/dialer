//
//  ChartInsight.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/10/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUICore

struct ChartInsight: Identifiable {
    let id: String?
    private let name: RecordType
    var transactions: [TransactionInsight]

    var count: Int {
        transactions.count
    }

    var totalAmount: Int {
        transactions.map(\.amount).reduce(0, +)
    }

    var title: String {
        name.rawValue.capitalized
    }

    var icon: Image {
        Image(systemName: iconName)
    }

    var iconName: String {
        switch name {
        case .merchant: "storefront"
        case .user: "person.fill"
        case .airtime: "simcard"
        case .other: "ellipsis"
        }
    }

    var color: Color {
        switch name {
        case .merchant: .orange
        case .user: .indigo
        case .airtime: .blue
        case .other: .red
        }
    }

    static func makeInsights(_ transactions: [TransactionInsight]) -> [ChartInsight] {
        var insightsResult = [ChartInsight]()

        for transaction in transactions {
            if let foundIndex = insightsResult.firstIndex(where: {
                $0.name == transaction.type
            }) {
                insightsResult[foundIndex].transactions.append(transaction)
            } else {
                let new = ChartInsight(
                    id: transaction.id,
                    name: transaction.type,
                    transactions: [transaction]
                )
                insightsResult.append(new)
            }

        }

        return insightsResult
    }

}
