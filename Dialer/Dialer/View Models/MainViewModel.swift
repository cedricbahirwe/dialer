//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
    @Published var pinCode: Int? = UserDefaults.standard.integer(forKey: UserDefaults.Keys.PinCode)
    @Published var showHistorySheet: Bool = false
    
    var estimatedTotalPrice: Int {
        recentCodes?.map(\.detail).map(\.amount).reduce(0, +) ?? 0
    }
    enum CodeType: String, Codable {
        case momo, call, message, other
    }
    struct RecentCode: Identifiable, Codable {
        public init(id: UUID = UUID(), detail: MainViewModel.PurchaseDetailModel, count: Int = 1) {
            self.id = id
            self.detail = detail
            self.count = count
        }
        
        private(set) var id: UUID
        
        public var detail: PurchaseDetailModel
        private(set) var count: Int
        
        public mutating func increaseCount() {
            count += 1
        }
        
        static let example = RecentCode(detail: .example)
        
    }
    
    struct PurchaseDetailModel: Codable {
        var amount: Int = 0
        var type: CodeType = .momo
        var fullCode: String {
            "*182*2*1*1*1*\(amount)*PIN#" // Need to check for the type to specify the prefix
        }
        static let example = PurchaseDetailModel()
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
    
    private let elements = "0123456789*#"
    
    @Published var purchaseDetail = PurchaseDetailModel()
    
    @Published var showbottomSheet: Bool = false
    
    @Published private(set) var recentCodes: [RecentCode]? = []
    
    
    /// <#Description#>
    /// - Parameter code: <#code description#>
    private func storeCode(code: RecentCode) {
        if let index = recentCodes?.firstIndex(where: { $0.detail.amount == code.detail.amount }) {
            recentCodes?[index].increaseCount()
        } else {
            recentCodes?.append(code)
        }
        saveLocally()
    }
    
    /// <#Description#>
    public func saveLocally() {
        if let encoded = try? JSONEncoder().encode(recentCodes){
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Keys.RecentCodes)
        } else {
            print("Couldn't encode")
        }
    }
    
    /// <#Description#>
    public func removePin() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.PinCode)
        pinCode = nil
    }
    
    /// <#Description#>
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
    
    /// <#Description#>
    public func confirmPurchase() {
        let purchase = purchaseDetail
        dialCode(url: purchaseDetail, completion: { result in
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
    
    /// <#Description#>
    /// - Parameter code: <#code description#>
    public func deleteRecentCode(code: RecentCode) {
        recentCodes?.removeAll(where: { $0.id == code.id })
        saveLocally()
    }
    
    /// <#Description#>
    /// - Parameter offSets: <#offSets description#>
    public func deleteRecentCode(at offSets: IndexSet) {
        recentCodes?.remove(atOffsets: offSets)
        saveLocally()
    }
    
    /// <#Description#>
    public func checkBalance() {
        performQuickDial(for: "*345*5#")
    }
    
    /// <#Description#>
    /// - Parameter value: <#value description#>
    public func savePinCode(value: Int) {
        if String(value).count == 5 {
            pinCode = value
            UserDefaults.standard.setValue(value, forKey: UserDefaults.Keys.PinCode)
        } else {
            print("Well, we can't save that pin")
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - type: <#type description#>
    ///   - completion: <#completion description#>
    private func dialCode(url: PurchaseDetailModel, type: CodeType = .momo, completion: @escaping (Result<String, MainViewModel.DialingError>) -> Void) {
        guard let code = pinCode else {
            completion(.failure(.emptyPin))
            return
        }
        let newUrl = url.fullCode.replacingOccurrences(of: "PIN", with: String(code))
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
    
    
    /// <#Description#>
    /// - Parameter code: <#code description#>
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
    
    
    /// <#Description#>
    /// - Parameter recentCode: <#recentCode description#>
    public func performRecentDialing(for recentCode: RecentCode) {
        let recent = recentCode
        dialCode(url: recentCode.detail) { result in
            switch result {
            case .success(_):
                self.storeCode(code: recent)
            case .failure(let error):
                print(error.message)
            }
        }
    }
}

extension UserDefaults {
    enum Keys {
        static let RecentCodes = "recentCodes"
        static let PinCode = "pinCode"
        static let PurchaseDetails = "purchaseDetails"
    }
}
