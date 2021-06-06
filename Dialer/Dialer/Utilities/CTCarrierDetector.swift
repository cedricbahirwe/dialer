//
//  CTCarrierDetector.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/06/2021.
//

import Foundation
import CoreTelephony

class CTCarrierDetector: NSObject {
    static let shared = CTCarrierDetector()
    
    func checkCellularProvider() -> (status: Bool, message: String) {
        let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders
        
        if let providers = providers?.compactMapValues({ $0.carrierName }),  !providers.isEmpty {
            let provider = providers.first!.value
            return (true, provider)
        }
        return (false, "No SIM found")
    }
}
