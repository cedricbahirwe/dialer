//
//  InsightHistoryViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation

final class InsightHistoryViewModel: ObservableObject {
    @Published private(set) var insight: InsightsView.Insight

    init(insight: InsightsView.Insight) {
        self.insight = insight
    }

}
