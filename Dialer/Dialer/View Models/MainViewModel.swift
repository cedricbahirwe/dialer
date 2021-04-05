//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
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
    
    struct PurchaseDetailModel {
        var amount: String = ""
        var code: String = ""
        
        var fullCode: String {
            "*182*2*1*1*1*\(amount)*\(code)#"
        }
    }
    
    func confirmPurchase() {
        
        dialCode(url: purchaseDetail.fullCode, completion: { result in
            switch result {
            case .success(let message):
                print("Message is", message)
            case .failure(let error):
                print(error.message)
            }
        })
    }
    
    func checkBalance() {
        composedCode = "*345*5#"
        dialCode(url: composedCode, completion: { result in
            switch result {
            case .success(let message):
                print("Message is", message)
            case .failure(let error):
                print(error.message)
            }
        })
        
    }
    
    private func dialCode(url: String, completion: @escaping (Result<String, MainViewModel.DialingError>) -> Void) {
        if let url = URL(string: "tel://\(url)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { hasOpened in
                print(hasOpened)
                completion(.success("Successfully Dialed"))
            })
            UIApplication.shared.endEditing(true)
            
        } else {
            // Can not dial this code
            completion(.failure(.canNotDial))
        }
    }
}
