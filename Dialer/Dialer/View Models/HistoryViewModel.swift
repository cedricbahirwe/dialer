//
//  HistoryViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/07/2023.
//

import Foundation

final class HistoryViewModel: ObservableObject {
    @Published private(set) var recentCodes: [RecentDialCode] = []

    var estimatedTotalPrice: Int {
        recentCodes.map(\.totalPrice).reduce(0, +)
    }

}
