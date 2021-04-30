//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
    @Published var pinCode: String? = UserDefaults.standard.value(forKey: UserDefaults.Keys.PinCode) as? String
    @Published var showHistorySheet: Bool = false
    
    struct RecentCode: Identifiable, Codable {
        var id = UUID()
        var code: String
        var count: Int = 1
        
        static let example = RecentCode(code: "*182#")
    }
    
    struct PurchaseDetailModel {
        var amount: String = ""
        var code: String = ""
        
        var fullCode: String {
            "*182*2*1*1*1*\(amount)*\(code)#"
        }
    }
    
    enum DialingError: Error {
        case canNotDial, other
        var message: String {
            switch self {
            case .canNotDial:
                return "Can not dial this code"
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
    
    private func storeCode(code: String) {
        if let index = recentCodes?.firstIndex(where: { $0.code == code }) {
            recentCodes?[index].count += 1
            
        } else {
            recentCodes?.append(.init(code: code))
        }
    }
    
    public func saveLocally() {
        if let encoded = try? JSONEncoder().encode(recentCodes){
            UserDefaults.standard.set(encoded, forKey: "recentCodes")
        } else {
            print("Couldn't encode")
        }
    }
    
    public func retrieveCodes() {
        guard let codes = UserDefaults.standard.object(forKey: "recentCodes") as? Data else {
            return
        }
        recentCodes =  try? JSONDecoder().decode([RecentCode].self, from: codes)
        
    }
    
    public func confirmPurchase() {
        if let code = pinCode {
            purchaseDetail.code = code
        }
        dialCode(url: purchaseDetail.fullCode, completion: { result in
            switch result {
            case .success(_): break
            case .failure(let error):
                print(error.message)
            }
        })
    }
    public func performQuickDial(for code: String) {
        
//        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.PinCode)
        dialCode(url: code, completion: { result in
            switch result {
            case .success(_): break
            case .failure(let error):
                print(error.message)
            }
        })
    }
    
    func deleteRecentCode(code: RecentCode) {
        recentCodes?.removeAll(where: { $0.id == code.id })
        saveLocally()
    }
    
    public func checkBalance() {
        composedCode = "*345*5#"
        dialCode(url: composedCode, completion: { result in
            switch result {
            case .success(_):break
            case .failure(let error):
                print(error.message)
            }
        })
        
    }
    
    public func savePinCode() {
        pinCode = purchaseDetail.code
        if let code = pinCode, code.count == 5 {
            UserDefaults.standard.setValue(code, forKey: UserDefaults.Keys.PinCode)
        }
    }
    
    private func dialCode(url: String, completion: @escaping (Result<String, MainViewModel.DialingError>) -> Void) {
        if let telUrl = URL(string: "tel://\(url)"),
           UIApplication.shared.canOpenURL(telUrl) {
            UIApplication.shared.open(telUrl, options: [:], completionHandler: { hasOpened in
                self.storeCode(code: url)
                completion(.success("Successfully Dialed"))
            })
            UIApplication.shared.endEditing(true)
            
        } else {
            // Can not dial this code
            completion(.failure(.canNotDial))
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
    }

}
