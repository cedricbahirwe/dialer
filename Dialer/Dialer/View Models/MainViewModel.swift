//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

protocol ClipBoardDelegate {
    func didSelectOption(with code: DialerQuickCode)
}

final class MainViewModel: ObservableObject {
    
    private(set) var history = HistoryViewModel()
    
    @Published var pinCode: CodePin? = DialerStorage.shared.getCodePin()
    
    /// Used to show Congratulations Screen
    @Published var hasReachSync = DialerStorage.shared.isSyncDateReached() {
        didSet(newValue) {
            if newValue == false {
                DialerStorage.shared.clearSyncDate()
            }
        }
    }

    var utilityDelegate: ClipBoardDelegate?
    
    @Published var purchaseDetail = PurchaseDetailModel()
    
    @Published private(set) var elecMeters: [ElectricityMeter] = []

    @Published private(set) var ussdCodes: [USSDCode] = []
    
    @Published var presentedSheet: Sheet?
    
    ///  Delete locally the Pin Code.
    func removePin() {
        DialerStorage.shared.removePinCode()
        pinCode = nil
    }

    /// Has user saved Code Pin
    func hasStoredCodePin() -> Bool {
        DialerStorage.shared.hasSavedCodePin()
    }
    
    /// Confirm and Purchase an entered Code.
    @MainActor
    func confirmPurchase() async {
        let purchase = purchaseDetail
        
        do {
            try await dialCode(from: purchase)
            history.storeCode(code: .init(detail: purchase))
            self.purchaseDetail = PurchaseDetailModel()
        } catch let error as DialingError {
            Log.debug(error.message)
        } catch let error {
            Log.debug(error.localizedDescription)
        }
        
    }
    
    /// Save locally the Code Pin
    /// - Parameter value: the pin value to be saved.
    func saveCodePin(_ value: CodePin) {
        pinCode = value
        do {
            try DialerStorage.shared.saveCodePin(value)
        } catch {
            Log.debug("Storage: \(error.localizedDescription)")
        }
    }
    
    /// Used on the `PuchaseDetailView` to dial, save code, save pin.
    /// - Parameters:
    ///   - purchase: the purchase to take the fullCode from.
    private func dialCode(from purchase: PurchaseDetailModel) async throws {
        
        let newUrl = purchase.getFullUSSDCode()
        
        if let telUrl = URL(string: "tel://\(newUrl)") {
            try await DialService.dial(telUrl)
        } else {
            throw DialingError.canNotDial
        }
    }
    
    func getPurchaseDetailUSSDCode() -> String {
        purchaseDetail.getFullUSSDCode()
    }
    
    /// Perform an independent dial, without storing or tracking.
    /// - Parameter code: a `DialerQuickCode`  code to be dialed.
    static func performQuickDial(for code: DialerQuickCode) async {
        if let telUrl = URL(string: "tel://\(code.ussd)") {
            do {
                let isCompleted = try await DialService.dial(telUrl)
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
    enum Sheet: Int, Identifiable {
        var id: Int { rawValue }
        case settings
        case history
    }
    
    func showHistoryView() {
        Tracker.shared.logEvent(.historyOpened)
        presentedSheet = .history
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
        if UIApplication.hasSupportForUSSD {
            Task {
                await Self.performQuickDial(for: quickCode)
            }
        } else {
            utilityDelegate?.didSelectOption(with: quickCode)
        }
    }

    func checkMobileWalletBalance() {
        performQuickDial(for: .mobileWalletBalance(code: pinCode))
    }

    func getElectricity(for meterNumber: String, amount: Int) {
        let number = meterNumber.replacingOccurrences(of: " ", with: "")
        performQuickDial(for: .electricity(meter: number, amount: amount, code: pinCode))
    }
}

// MARK: Electricity Storage
extension MainViewModel {
    
    func containsMeter(with number: String) -> Bool {
        guard let meter = try? ElectricityMeter(number) else { return false }
        return elecMeters.contains(meter)
    }

    /// Store a given  `MeterNumber`  locally.
    /// - Parameter code: the code to be added.
    func storeMeter(_ number: ElectricityMeter) {
        guard elecMeters.contains(where: { $0.id == number.id }) == false else { return }
        elecMeters.append(number)
        saveMeterNumbersLocally(elecMeters)
    }

    /// Save MeterNumber(s) locally.
    private func saveMeterNumbersLocally(_ meters: [ElectricityMeter]) {
        do {
            try DialerStorage.shared.saveElectricityMeters(meters)
        } catch {
            Tracker.shared.logError(error: error)
            Log.debug("Could not save meter numbers locally: ", error.localizedDescription)
        }
    }

    /// Retrieve all locally stored Meter Numbers codes
    func retrieveMeterNumbers() {
        elecMeters = DialerStorage.shared.getMeterNumbers()
    }

    func deleteMeter(at offSets: IndexSet) {
        elecMeters.remove(atOffsets: offSets)
        saveMeterNumbersLocally(elecMeters)
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
    
    /// - Tag: QuickActionUserInfo
    var quickActionUserInfo: [String: NSSecureCoding] {
        /** Encode the id of the recent code into the userInfo dictionary so it can be passed
         back when a quick action is triggered.
         */
        return [ SceneDelegate.codeIdentifierInfoKey: self.id.uuidString as NSSecureCoding ]
    }
}

// MARK: - Extension for `PurchaseDetailView` methods
extension MainViewModel {
    var hasValidAmount: Bool {
        purchaseDetail.amount >= AppConstants.minAmount
    }
    
    var isPinCodeValid: Bool {
        pinCode?.asString.count == 5
    }
}
