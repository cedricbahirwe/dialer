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
    
    /// Perform a quick dialing from the `History View Row.`
    /// - Parameter recentCode: the row code to be performed.
    func performRecentDialing(for recentCode: RecentDialCode) {
        let recent = recentCode
        Task {
            do {
                try await recentCode.detail.dialCode()
                storeCode(code: recent)
            } catch let error as DialingError {
                Log.debug(error.message)
            }
        }
    }
    
    /// Store a given  `RecentCode`  locally.
    /// - Parameter code: the code to be added.
    func storeCode(code: RecentDialCode) {
        if let index = recentCodes.firstIndex(where: { $0.detail.amount == code.detail.amount }) {
            recentCodes[index].increaseCount()
        } else {
            recentCodes.append(code)
        }
        saveRecentCodesLocally()
    }
    
    /// Retrieve all locally stored recent codes.
    func retrieveHistoryCodes() {
        recentCodes = DialerStorage.shared.getSortedRecentCodes()
    }
    
    /// Delete locally the used Code(s).
    /// - Parameter offSets: the offsets to be deleted
    func deletePastCode(at offSets: IndexSet) {
        recentCodes.remove(atOffsets: offSets)
        saveRecentCodesLocally()
    }
    
    /// Returns a `RecentDialCode` that matches the identifier.
    func getRecentDialCode(with identifier: String) -> RecentDialCode? {
        recentCodes.first(where: { $0.id.uuidString == identifier })
    }
    
    /// Save RecentCode(s) locally.
    func saveRecentCodesLocally() {
        do {
            try DialerStorage.shared.saveRecentCodes(recentCodes)
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Could not save recent codes locally: ", error.localizedDescription)
        }
    }
}
