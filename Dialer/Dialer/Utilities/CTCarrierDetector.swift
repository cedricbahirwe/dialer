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
    
    func cellularProvider() -> (status: Bool, message: String) {
        let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders
        
        if let providers = providers?
            .filter({  $0.value.mobileCountryCode != nil })
            .compactMapValues(\.carrierName),
           providers.isEmpty == false
        {
            let provider = providers.first!.value
            return (true, provider)
        }
        return (false, "No SIM found")
    }
}
