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

    var capitalized: String {
        rawValue.capitalized
    }
}

@MainActor
class DialerInsightStore: BaseViewModel {

    @Published private(set) var transactionInsights: [TransactionInsight]

    var generalTotal: Int {
        transactionInsights.map(\.amount).reduce(0, +)
    }

    let periods = InsightFilterPeriod.allCases
    @Published private(set) var selectedPeriod = InsightFilterPeriod.year

    private var filteredInsightsByPeriod: [TransactionInsight] {
        filterInsightsByPeriod(transactionInsights, period: selectedPeriod)
    }

    var chartInsights: [ChartInsight] {
        ChartInsight.makeInsights(filteredInsightsByPeriod)
    }

    private let insightsProvider: InsightProtocol

    init(_ insightsProvider: InsightProtocol = FirebaseManager()) {
        self.transactionInsights = []
        self.insightsProvider = insightsProvider
        super.init()
        Task {
            await getInsights()
        }
    }

    func getPopularInsight() -> ChartInsight? {
        chartInsights.sorted(by: { $0.totalAmount >  $1.totalAmount }).first
    }

    func getMostActiveMonth() -> (month: String, count: Int)? {
        let dates = transactionInsights.map(\.createdDate)
        guard !dates.isEmpty else { return nil }

        // Create a calendar instance
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")

        // Dictionary to count occurrences of each month
        var monthCounts: [Int: Int] = [:]

        // Count dates by their month
        for date in dates {
            let month = calendar.component(.month, from: date)
            monthCounts[month, default: 0] += 1
        }

        // Find the most active month
        if let (mostActiveMonth, count) = monthCounts.max(by: { $0.value < $1.value }) {
            let monthName = calendar.monthSymbols[mostActiveMonth - 1]
            return (month: monthName, count: count)
        }

        return nil
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
        self.transactionInsights = sortedInsights
    }

    func createInsight(_ insight: TransactionInsight) async -> Bool {
        let savedDevice = DialerStorage.shared.getSavedDevice()
        let device = savedDevice ?? FirebaseTracker.getDevice()
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

    private func filterInsightsByPeriod(_ insights: [TransactionInsight], period: InsightFilterPeriod) -> [TransactionInsight] {
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
