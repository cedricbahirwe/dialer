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
    @Published var showHistorySheet: Bool = false
    
    var estimatedTotalPurchasesPirce: Int {
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
        case canNotDial, unknownFormat(String),  other
        var message: String {
            switch self {
            case .canNotDial:
                return "Can not dial this code"
            case .unknownFormat(let format):
                return "Can not decode this format: \(format)"
            default:
                return "Unknown error occured"
            }
        }
    }
    private let elements = "0123456789*#"
    
    @Published var composedCode: String = ""
    
    @Published var purchaseDetail = PurchaseDetailModel()
    
    @Published var showbottomSheet: Bool = false
    
    
    @Published private(set) var recentCodes: [RecentCode]? = []
    
    
    private func storeCode(code: RecentCode) {
        if let index = recentCodes?.firstIndex(where: { $0.id == code.id }) {
            recentCodes?[index].increaseCount()
        } else {
            recentCodes?.append(code)
        }
        saveLocally()
    }
    
    public func saveLocally() {
        if let encoded = try? JSONEncoder().encode(recentCodes){
            UserDefaults.standard.set(encoded, forKey: UserDefaults.Keys.RecentCodes)
        } else {
            print("Couldn't encode")
        }
    }
    
    public func retrieveCodes() {
        guard let codes = UserDefaults
                .standard
                .object(forKey: UserDefaults.Keys.RecentCodes) as? Data else {
            print("Cannot fins da")
            return
        }
        do {
            print(codes)
            recentCodes =  try JSONDecoder().decode([RecentCode].self, from: codes)
        } catch let error {
            print("Couldn't decode")
            print(error.localizedDescription)
        }
    }
    
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
    public func deleteRecentCode(code: RecentCode) {
        recentCodes?.removeAll(where: { $0.id == code.id })
        saveLocally()
    }
    
    public func deleteRecentCode(at offSets: IndexSet) {
        recentCodes?.remove(atOffsets: offSets)
        saveLocally()
    }
    
    public func checkBalance() {
        performQuickDial(for: "*345*5#")
    }
    
    public func savePinCode(value: Int) {
        if String(value).count == 5 {
            pinCode = value
            UserDefaults.standard.setValue(value, forKey: UserDefaults.Keys.PinCode)
        } else {
            print("Well, we can't save that pin")
        }
    }
    
    private func dialCode(url: PurchaseDetailModel, type: CodeType = .momo, completion: @escaping (Result<String, MainViewModel.DialingError>) -> Void) {
        guard let code = pinCode else { return }
        let newUrl = url.fullCode.replacingOccurrences(of: "PIN", with: String(code))
        if let telUrl = URL(string: "tel://\(newUrl)"),
           UIApplication.shared.canOpenURL(telUrl) {
            UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in
                completion(.success("Successfully Dialed"))
            })
            UIApplication.shared.endEditing(true)
            
        } else {
            // Can not dial this code
            completion(.failure(.canNotDial))
        }
    }
    
    public func performQuickDial(for code: String) {
        if let telUrl = URL(string: "tel://\(code)"),
           UIApplication.shared.canOpenURL(telUrl) {
            UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in
                print("Successfully Dialed")
            })
            UIApplication.shared.endEditing(true)
            
        } else {
            print("Can not dial this code")
        }
    }
    
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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension UserDefaults {
    enum Keys {
        static let RecentCodes = "recentCodes"
        static let PinCode = "pinCode"
        static let PurchaseDetails = "purchaseDetails"
    }
}
