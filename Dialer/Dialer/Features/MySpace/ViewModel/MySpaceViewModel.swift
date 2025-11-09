//
//  MySpaceViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation

final class MySpaceViewModel: BaseViewModel {
    @Published private(set) var ussdCodes: [CustomUSSDCode] = []
    private let storage: DialerStorage

    init(storage: DialerStorage = .shared) {
        self.storage = storage
    }

    /// Store a given  `USSDCode`  locally.
    /// - Parameter code: the code to be added.
    func storeUSSD(_ code: CustomUSSDCode) {
        guard ussdCodes.contains(where: { $0 == code }) == false else { return }
        ussdCodes.append(code)
        saveUSSDCodesLocally(ussdCodes)
    }

    /// Update an existing `USSDCode` locally.
    /// - Parameter code: the code to be updated
    func updateUSSD(_ code: CustomUSSDCode) {
        if let index = ussdCodes.firstIndex(of: code) {
            ussdCodes[index] = code
        }
        saveUSSDCodesLocally(ussdCodes)
    }

    /// Save USSDCode(s) locally.
    private func saveUSSDCodesLocally(_ codes: [CustomUSSDCode]) {
        do {
            try DialerStorage.shared.saveUSSDCodes(codes)
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Could not save ussd codes locally: ", error.localizedDescription)
        }
    }

    func retrieveUSSDCodes() {
        ussdCodes = DialerStorage.shared.getUSSDCodes()
    }

    func deleteUSSD(at offSets: IndexSet) {
        ussdCodes.remove(atOffsets: offSets)
        saveUSSDCodesLocally(ussdCodes)
    }

    func deleteUSSD(_ code: CustomUSSDCode) {
        ussdCodes.removeAll(where: { $0 == code })
        saveUSSDCodesLocally(ussdCodes)
    }

    func removeAllUSSDs() {
        DialerStorage.shared.removeAllUSSDCodes()
        ussdCodes = []
    }
}
