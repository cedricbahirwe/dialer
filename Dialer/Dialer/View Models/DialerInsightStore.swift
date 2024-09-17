//
//  DialerInsightStore.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 17/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class DialerInsightStore: BaseViewModel {
    @Published private(set) var insights: [TransactionInsight]
    private let insightsProvider: InsightProtocol

    init(_ insightsProvider: InsightProtocol = FirebaseManager()) {
        self.insights = []
        self.insightsProvider = insightsProvider
        super.init()
        Task {
            await getInsights()
        }
    }

    @MainActor
    func getInsights() async {
        startFetch()
        let result = await insightsProvider.getAllInsights()
        stopFetch()
        let sortedInsights = result.sorted(by: {
            $0.createdDate > $1.createdDate
        })
        self.insights = sortedInsights
    }

    func createInsight(_ insight: TransactionInsight) async -> Bool {
        let savedDevice = DialerStorage.shared.getSavedDevice()
        let device = savedDevice ?? FirebaseTracker.makeDeviceAccount()
        var insightToUpdate = insight
        insightToUpdate.ownerID = device.deviceHash

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

}
