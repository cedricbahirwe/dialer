//
//  DialerService.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation

final class DialerService: ObservableObject {
    @Published private(set) var ussdCodes: [USSDCode] = []

    /// Perform an airtime purchase transaction
    @MainActor func buyAirtime(_ transaction: AirtimeTransaction) async {
        await dialCode(for: transaction)
        Tracker.shared.logTransaction(record: .airtime(transaction))
    }

    /// Perform a Momo transaction
    /// - Parameter transaction: the user transaction
    func transferMoney(_ transaction: Transaction.Model) async {
        guard transaction.isValid else {
            Log.debug("Transaction is invalid: \(transaction.fullUSSDCode)")
            return
        }

        await dialCode(for: transaction)
        Tracker.shared.logTransaction(transaction: transaction.toParent())
    }

    /// Perform an independent dial, without storing or tracking.
    /// - Parameter code: a `DialerQuickCode`  code to be dialed.
    func dialCode(for dialCode: Dialable) async {
        guard let telUrl = try? PhoneService.shared.getDialURL(from: dialCode.fullUSSDCode) else {
            Log.debug("DialerService Can not dial this code: \(dialCode.fullUSSDCode)")
            return
        }

        do {
            try await PhoneService.shared.dial(telUrl)
            Log.debug("DialerService Successfully Dialed")
        } catch let error as DialingError {
            Log.debug("DialerService Interal Error: \(error.message)")
        } catch {
            Log.debug("DialerService Unknow Error: \(error.localizedDescription)")
        }
    }
}

// MARK: Custom USSD Storage
extension DialerService {
    /// Store a given  `USSDCode`  locally.
    /// - Parameter code: the code to be added.
    func storeUSSD(_ code: USSDCode) {
        guard ussdCodes.contains(where: { $0 == code }) == false else { return }
        ussdCodes.append(code)
        saveUSSDCodesLocally(ussdCodes)
    }

    /// Update an existing `USSDCode` locally.
    /// - Parameter code: the code to be updated
    func updateUSSD(_ code: USSDCode) {
        if let index = ussdCodes.firstIndex(of: code) {
            ussdCodes[index] = code
        }
        saveUSSDCodesLocally(ussdCodes)
    }

    /// Save USSDCode(s) locally.
    private func saveUSSDCodesLocally(_ codes: [USSDCode]) {
        do {
            try DialerStorage.shared.saveUSSDCodes(codes)
        } catch {
            Tracker.shared.logError(error: error)
            Log
                .debug(
                    "Could not save ussd codes locally: ",
                    error.localizedDescription
                )
        }
    }

    /// Retrieve all locally stored Meter Numbers codes
    func retrieveUSSDCodes() {
        ussdCodes = DialerStorage.shared.getUSSDCodes()
    }

    func deleteUSSD(at offSets: IndexSet) {
        ussdCodes.remove(atOffsets: offSets)
        saveUSSDCodesLocally(ussdCodes)
    }

    func removeAllUSSDs() {
        DialerStorage.shared.removeAllUSSDCodes()
        ussdCodes = []
    }
}
