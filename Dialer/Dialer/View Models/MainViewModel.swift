//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI


class MainViewModel: ObservableObject {
    
    @Published var pinCode: Int? = UserDefaults.standard.value(forKey: UserDefaults.Keys.PinCode) as? Int
    @Published var hasReachSync: Bool = hasSyncDateExpired( UserDefaults.standard.value(forKey: UserDefaults.Keys.LastSyncDate) as? Date ?? Date()) {
        didSet {
            if !hasReachSync {
                UserDefaults.standard.setValue(nil, forKey: UserDefaults.Keys.LastSyncDate)
            }
        }
    }
    @Published var showHistorySheet: Bool = false
    
    var estimatedTotalPrice: Int {
        recentCodes?.map(\.totalPrice).reduce(0, +) ?? 0
    }

    private let elements = "0123456789*#"
    
    @Published var purchaseDetail = PurchaseDetailModel()
    
    @Published var showbottomSheet: Bool = false
    
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
        if let encoded = try? JSONEncoder().encode(recentCodes){
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Keys.RecentCodes)
        } else {
            print("Couldn't encode")
        }
    }
    
    ///  Delete locally the Pin Code.
    public func removePin() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.PinCode)
        pinCode = nil
    }
    
    /// Retrieve all locally stored recent codes.
    public func retrieveCodes() {
        guard let codes = UserDefaults
                .standard
                .object(forKey: UserDefaults.Keys.RecentCodes) as? Data else {
            return
        }
        do {
            recentCodes =  try JSONDecoder().decode([RecentCode].self, from: codes)
        } catch let error {
            print("Couldn't decode")
            print(error.localizedDescription)
        }
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
        performQuickDial(for: "*345*5#")
    }
    
    /// Save locally the Pin Code
    /// - Parameter value: the pin value to be saved.
    public func savePinCode(value: Int) {
        if String(value).count == 5 {
            pinCode = value
            UserDefaults.standard.setValue(value, forKey: UserDefaults.Keys.PinCode)
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
    public func performQuickDial(for code: String) {
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
    
    static func storeSyncDate() {
        let syncDateKey =  UserDefaults.Keys.LastSyncDate
        if UserDefaults.standard.value(forKey: syncDateKey) != nil { return }
        UserDefaults.standard.setValue(Date(), forKey: syncDateKey)
    }
    static func hasSyncDateExpired(_ date: Date) -> Bool {
        return Date().timeIntervalSince(date) / 86400 > 30 // TO check if 30 Days have passed
    }
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
        
        public var detail: PurchaseDetailModel
        private(set) var count: Int
        var totalPrice: Int {
            detail.amount * count
        }
        public mutating func increaseCount() {
            count += 1
        }
        
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


extension MainViewModel.RecentCode {
    
    /// - Tag: QuickActionUserInfo
    var quickActionUserInfo: [String: NSSecureCoding] {
        /** Encode the id of the recent code into the userInfo dictionary so it can be passed
         back when a quick action is triggered.
         */
        return [ SceneDelegate.codeIdentifierInfoKey: self.id.uuidString as NSSecureCoding ]
    }
}

extension UserDefaults {
    
    /// Storing the used UserDefaults keys for safety.
    enum Keys {
        static let RecentCodes = "recentCodes"
        static let PinCode = "pinCode"
        static let PurchaseDetails = "purchaseDetails"
        static let LastSyncDate = "lastSyncDate"
    }
}
