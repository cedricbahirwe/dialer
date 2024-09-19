//
//  AirtimeToInsightMigrator.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation

actor AirtimeToInsightMigrator {
    static let shared = AirtimeToInsightMigrator()
    private var isMigrating = false
    private let store: FirebaseCRUD
    
    private init(store: FirebaseCRUD = FirebaseManager()) {
        self.store = store
    }

    func migrate() async {
        guard !isMigrating else { return }
        let storedCodes = DialerStorage.shared.getSortedRecentCodes()
        print("Finding", storedCodes.count)
        guard !storedCodes.isEmpty else { return }
        guard let device = DialerStorage.shared.getSavedDevice() else { return }

        isMigrating = true

        let transactions: [TransactionInsight] = storedCodes.map { recentCode in
            TransactionInsight(
                createdDate: recentCode.detail.purchaseDate,
                details: .airtime(recentCode.detail),
                ownerID: device.deviceHash
            )
        }

        do {
            try await store.createBatches(transactions, in: .transactions)
            // Clear old codes if migration was completed
            DialerStorage.shared.clearRecentCodes()
            isMigrating = false
        } catch {
            Log.debug("Failed to create batches in migration: \(error.localizedDescription)")
            isMigrating = false
        }
    }
}
