//
//  MainViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var selectedCode: String = ""
    @Published var selectedDialer: DialerOption? = nil
    
    @Published var error: (state: Bool, message: String) = (false, "")
    let elements = "0123456789*#"
    
    func dial() {

        switch selectedDialer {
        case .airtimeBalance:
            if let dialer = selectedDialer {
                dialCode(url: dialer.value)
            }
            return
        default:
            break
        }
        if !selectedCode.isEmpty {
            dialCode(url: selectedCode)
        } else {
            self.error = (true, "Enter a valid code")
        }
    }
    
    
    func dialCode(url: String) {
        if let url = URL(string: "tel://\(url)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { hasOpened in
                print(hasOpened)
            })
            self.error.state = false
            selectedCode = ""
            UIApplication.shared.endEditing(true)
        } else {
            // Can not dial this code
            self.error = (true, "Can not dial this code")
//            let alert = UIAlertController(title: "", message: "Can not call this number", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
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
    static func dialCode(url: String, completion: @escaping (Result<String, MainViewModel.DialingError>) -> Void) {
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
    
    func checkError() throws {
    
    }
}
