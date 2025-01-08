//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

final class MainViewModel: ObservableObject {
    
//    private(set) var history = HistoryViewModel()
        
    /// Used to show Congratulations Screen
//    @Published var hasReachSync = DialerStorage.shared.isSyncDateReached() {
//        didSet(newValue) {
//            if newValue == false {
//                DialerStorage.shared.clearSyncDate()
//            }
//        }
//    }
    
    @Published var purchaseDetail = AirtimeTransaction()
    
    @Published private(set) var ussdCodes: [USSDCode] = []
    
    @Published var presentedSheet: DialerSheet?
    
    /// Confirm and Purchase an entered Code.
    @MainActor
    func confirmPurchase() async {
        let purchase = purchaseDetail
        
        do {
            try await dialCode(from: purchase)
            Tracker.shared.logTransaction(record: .airtime(purchase))
            self.purchaseDetail = AirtimeTransaction()
        } catch let error as DialingError {
            Log.debug(error.message)
        } catch let error {
            Log.debug(error.localizedDescription)
        }
    }
    
    /// Used on the `PuchaseDetailView` to dial, save code, save pin.
    /// - Parameters:
    ///   - purchase: the purchase to take the fullCode from.
    private func dialCode(from purchase: AirtimeTransaction) async throws {
        
        let newUrl = purchase.getFullUSSDCode()
        
        if let telUrl = URL(string: "tel://\(newUrl)") {
            try await DialService.shared.dial(telUrl)
        } else {
            throw DialingError.canNotDial
        }
    }
    
    /// Perform an independent dial, without storing or tracking.
    /// - Parameter code: a `DialerQuickCode`  code to be dialed.
    static func performQuickDial(for code: DialerQuickCode) async {
        if let telUrl = URL(string: "tel://\(code.ussd)") {
            do {
                let isCompleted = try await DialService.shared.dial(telUrl)
                if isCompleted {
                    Log.debug("Successfully Dialed")
                } else {
                    Log.debug("Failed Dialed")
                }
            } catch {
                Log.debug("Failed Dialed \(error.localizedDescription)")
            }
            
        } else {
            Log.debug("Can not dial this code")
        }
    }
    
}

// MARK: - Sheets presentation
extension MainViewModel {
    enum DialerSheet: Int, Identifiable {
        var id: Int { rawValue }
        case settings
    }

    func showSettingsView() {
        Tracker.shared.logEvent(.settingsOpened)
        presentedSheet = .settings
    }

    func dismissSettingsView() {
        presentedSheet = nil
    }
}

// MARK: - Quick USSD actions.
extension MainViewModel {
    private func performQuickDial(for quickCode: DialerQuickCode) {
        Task {
            await Self.performQuickDial(for: quickCode)
        }
    }
}

// MARK: Custom USSD Storage
extension MainViewModel {
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
            Log.debug("Could not save ussd codes locally: ", error.localizedDescription)
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

// MARK: - Extension used for Home Quick Actions
extension RecentDialCode {
    static let codeIdentifierInfoKey = "CodeIdentifier"
    
    /// - Tag: QuickActionUserInfo
    var quickActionUserInfo: [String: NSSecureCoding] {
        /** Encode the id of the recent code into the userInfo dictionary so it can be passed
         back when a quick action is triggered.
         */
        return [ RecentDialCode.codeIdentifierInfoKey: self.id.uuidString as NSSecureCoding ]
    }
}

// MARK: - Extension for `PurchaseDetailView` methods
extension MainViewModel {
    var hasValidAmount: Bool {
        purchaseDetail.amount >= AppConstants.minAmount
    }
}
