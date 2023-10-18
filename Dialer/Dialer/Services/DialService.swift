//
//  DialService.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 18/10/2023.
//

import UIKit

struct DialService {
    
    private init() { }
    
    @MainActor
    @discardableResult
    static func dial(_ telUrl: URL) async throws -> Bool {
        guard UIApplication.shared.canOpenURL(telUrl) else {
            throw DialingError.canNotDial
        }
        
        let isCompleted = await UIApplication.shared.open(telUrl)
        if !isCompleted { throw DialingError.canNotDial }
        return isCompleted
    }
}
