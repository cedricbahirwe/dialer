//
//  DialerInsightStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 17/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUI

enum InsightFilterPeriod: String, CaseIterable {
    case week
    case month
    case year

    var capiltalized: String {
        rawValue.capitalized
    }
}

@MainActor
class DialerInsightStore: BaseViewModel {

    @Published private var allInsights: [TransactionInsight]
    let periods = InsightFilterPeriod.allCases
    @Published private(set) var selectedPeriod = InsightFilterPeriod.year

    var filteredInsightsByPeriod: [TransactionInsight] {
        filterInsightsByPeriod(allInsights, period: selectedPeriod)
    }

    private let insightsProvider: InsightProtocol

    init(_ insightsProvider: InsightProtocol = FirebaseManager()) {
        self.allInsights = []
        self.insightsProvider = insightsProvider
        super.init()
        Task {
            await getInsights()
        }
    }

    func setFilterPeriod(_ period: InsightFilterPeriod) {
        guard selectedPeriod != period else { return }
        self.selectedPeriod = period
    }

    func getInsights() async {
        guard let device = DialerStorage.shared.getSavedDevice() else { return }
        startFetch()
        let result = await insightsProvider.getInsights(for: device.deviceHash)
        stopFetch()
        let sortedInsights = result.sorted(by: {
            $0.createdDate > $1.createdDate
        })
        self.allInsights = sortedInsights
    }

    func createInsight(_ insight: TransactionInsight) async -> Bool {
        let savedDevice = DialerStorage.shared.getSavedDevice()
        let device = savedDevice ?? FirebaseTracker.makeDeviceAccount()
        var insightToUpdate = insight
        insightToUpdate.ownerId = device.deviceHash

        startFetch()
        do {
            let isSaved = try await insightsProvider.saveInsight(insightToUpdate)
            stopFetch()

            await getInsights()
            return isSaved
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Could not save insight: ", error)
            stopFetch()
            return false
        }
    }

    func filterInsightsByPeriod(_ insights: [TransactionInsight], period: InsightFilterPeriod) -> [TransactionInsight] {
        let calendar = Calendar.current
        let now = Date()

        switch period {
        case .week:
            guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
                return []
            }
            return insights.filter { $0.createdDate >= startOfWeek }

        case .month:
            guard let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start else {
                return []
            }
            return insights.filter { $0.createdDate >= startOfMonth }

        case .year:
            guard let startOfYear = calendar.dateInterval(of: .year, for: now)?.start else {
                return []
            }
            return insights.filter { $0.createdDate >= startOfYear }
        }
    }
}
