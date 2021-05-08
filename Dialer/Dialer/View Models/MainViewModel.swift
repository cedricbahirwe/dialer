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
    
    enum CodeType: String, Codable {
        case momo, call, message, other
    }
    struct RecentCode: Identifiable, Codable {
        var id = UUID()
        var detail: PurchaseDetailModel = .example
        var count: Int = 0
        
        static let example = RecentCode()
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
            recentCodes?[index].count += 1
            
        } else {
            recentCodes?.append(code)
        }
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
            return
        }
        do {
            recentCodes =  try JSONDecoder().decode([RecentCode].self, from: codes)
        } catch let error {
            print("Couldn't decode")
            print(error.localizedDescription)
        }
    }
    
    public func confirmPurchase() {
        dialCode(url: purchaseDetail, completion: { result in
            switch result {
            case .success(_): break
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
        if url.fullCode.allSatisfy({ elements.contains($0)}) {
            if let telUrl = URL(string: "tel://\(newUrl)"),
               UIApplication.shared.canOpenURL(telUrl) {
                UIApplication.shared.open(telUrl, options: [:], completionHandler: { hasOpened in
                    if !hasOpened {
                        print("The thing did not open")
                    }
                    self.storeCode(code: RecentCode(detail: PurchaseDetailModel(amount: <#T##Int#>, type: type), count: 1))
                    completion(.success("Successfully Dialed"))
                })
                UIApplication.shared.endEditing(true)
                
            } else {
                // Can not dial this code
                completion(.failure(.canNotDial))
            }
        }
    }
    
    public func performQuickDial(for code: String) {
        if let telUrl = URL(string: "tel://\(code)"),
           UIApplication.shared.canOpenURL(telUrl) {
            UIApplication.shared.open(telUrl, options: [:], completionHandler: { hasOpened in
                if !hasOpened {
                    print("The thing did not open")
                }
                print("Successfully Dialed")
            })
            UIApplication.shared.endEditing(true)
            
        } else {
            print("Can not dial this code")
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
