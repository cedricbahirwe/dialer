//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
    @Published var pinCode: Int? = DialerStorage.shared.getPinCode()
    @Published var hasReachSync = DialerStorage.shared.isSyncDateReached() {
        didSet(newValue) {
            if newValue == false {
                DialerStorage.shared.clearSyncDate()
            }
        }
    }
    
    public var hasStoredPinCode: Bool {
        DialerStorage.shared.hasPinCode
    }
    
    // Present a sheet contains all dialed code
    @Published var showHistorySheet: Bool = false
    
    // Present a sheet contains settings of the app
    @Published var showSettingsSheet: Bool = false
    
    var estimatedTotalPrice: Int {
        recentCodes?.map(\.totalPrice).reduce(0, +) ?? 0
    }
    
    @Published var purchaseDetail = PurchaseDetailModel()
    
    
    // TODO: why is this optional!!
    @Published private(set) var recentCodes: [RecentCode]? = []
    
    
    /// Store a given  recent code locally.
    /// - Parameter code: the code to be added.
    private func storeCode(code: RecentCode) {
        if let index = recentCodes?.firstIndex(where: { $0.detail.amount == code.detail.amount }) {
            recentCodes?[index].increaseCount()
        } else {
            recentCodes?.append(code)
        }
        saveLocally()
    }
    
    /// Save code(s) locally.
    public func saveLocally() {
        do {
            try DialerStorage.shared.saveRecentCodes(recentCodes)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    ///  Delete locally the Pin Code.
    public func removePin() {
        DialerStorage.shared.removePinCode()
        pinCode = nil
    }
    
    /// Retrieve all locally stored recent codes.
    public func retrieveCodes() {
        recentCodes = DialerStorage.shared.getRecentCodes()
    }
    
    /// Confirm and Purchase an entered Code.
    public func confirmPurchase() {
        let purchase = purchaseDetail
        dialCode(from: purchaseDetail, completion: { result in
            switch result {
            case .success(_):
                self.storeCode(code: RecentCode(detail: purchase))
                self.purchaseDetail = PurchaseDetailModel()
                
                break;
            case .failure(let error):
                print(error.message)
            }
        })
        
    }
    
    /// Delete locally the recent Code(s).
    /// - Parameter offSets: the offsets to be deleted
    public func deleteRecentCode(at offSets: IndexSet) {
        recentCodes?.remove(atOffsets: offSets)
        saveLocally()
    }
    
    /// Check internet balance.
    public func checkInternetBalance() {
        Self.performQuickDial(for: "*345*5#")
    }
    
    /// Save locally the Pin Code
    /// - Parameter value: the pin value to be saved.
    public func savePinCode(value: Int) {
        if String(value).count == 5 {
            pinCode = value
            DialerStorage.shared.savePinCode(value)
        } else {
            print("Well, we can't save that pin")
        }
    }
    
    /// Used on the `PuchaseDetailView` to dial, save code, save pin.
    /// - Parameters:
    ///   - purchase: the purchase to take the fullCode from.
    ///   - completion: closue to return a success message or a error of type   `DialingError`.
    private func dialCode(from purchase: PurchaseDetailModel, completion: @escaping (Result<String, MainViewModel.DialingError>) -> Void) {
        
        let code: String
        if let _ = pinCode, String(pinCode!).count >= 5 {
            code = String(pinCode!)
        } else {
            code = ""
        }
        
        let newUrl = purchase.getDialCode(pin: code)
        if let telUrl = URL(string: "tel://\(newUrl)"),
           UIApplication.shared.canOpenURL(telUrl) {
            UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in
                completion(.success("Successfully Dialed"))
            })
            
        } else {
            // Can not dial this code
            completion(.failure(.canNotDial))
        }
    }
    
    /// Returns a Recent Code that matches the input identifier.
    func rencentCode(_ identifier: String) -> RecentCode? {
        let foundCode = recentCodes?.first(where: { $0.id.uuidString == identifier})
        return foundCode
    }
    
    /// Perform an independent dial, without storing or tracking.
    /// - Parameter code: the `string` code to be dialed.
    public static func performQuickDial(for code: String) {
        if let telUrl = URL(string: "tel://\(code)"),
           UIApplication.shared.canOpenURL(telUrl) {
            UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in
                print("Successfully Dialed")
            })
            
        } else {
            print("Can not dial this code")
        }
    }
    
    /// Perfom a quick dialing from the `History View Row.`
    /// - Parameter recentCode: the row code to be performed.
    public func performRecentDialing(for recentCode: RecentCode) {
        let recent = recentCode
        dialCode(from: recentCode.detail) { result in
            switch result {
            case .success(_):
                self.storeCode(code: recent)
            case .failure(let error):
                print(error.message)
            }
        }
    }
}
extension MainViewModel {
    
    enum DialingError: Error {
        case canNotDial, emptyPin, unknownFormat(String),  other
        var message: String {
            switch self {
            case .canNotDial:
                return "Can not dial this code"
            case .unknownFormat(let format):
                return "Can not decode this format: \(format)"
            case .emptyPin:
                return "Pin Code not found, configure pin and try again"
            default:
                return "Unknown error occured"
            }
        }
    }
    
    enum CodeType: String, Codable {
        case momo, call, message, other
    }
    struct RecentCode: Identifiable, Hashable, Codable {
        static func == (lhs: MainViewModel.RecentCode, rhs: MainViewModel.RecentCode) -> Bool {
            lhs.id == rhs.id
        }
        
        public init(id: UUID = UUID(), detail: MainViewModel.PurchaseDetailModel, count: Int = 1) {
            self.id = id
            self.detail = detail
            self.count = count
        }
        
        private(set) var id: UUID
        private(set) var count: Int
        var detail: PurchaseDetailModel
        var totalPrice: Int { detail.amount * count }
        
        mutating func increaseCount() { count += 1 }
        
        static let example = RecentCode(detail: .example)
        
    }
        
    struct PurchaseDetailModel: Hashable, Codable {
        var amount: Int = 0
        var type: CodeType = .momo
        var fullCode: String {
            "*182*2*1*1*1*\(amount)*PIN#"
        }
        
        func getDialCode(pin: String) -> String {
            if pin.isEmpty {
                return "*182*2*1*1*1*\(amount)#"
            } else {
                return "*182*2*1*1*1*\(amount)*\(pin)#"
            }
        }
        static let example = PurchaseDetailModel()
    }
}


// Extension used for Home Quick Actions
extension MainViewModel.RecentCode {
    
    /// - Tag: QuickActionUserInfo
    var quickActionUserInfo: [String: NSSecureCoding] {
        /** Encode the id of the recent code into the userInfo dictionary so it can be passed
         back when a quick action is triggered.
         */
        return [ SceneDelegate.codeIdentifierInfoKey: self.id.uuidString as NSSecureCoding ]
    }
}
