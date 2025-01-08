//
//  DialService.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 18/10/2023.
//

import UIKit

struct DialService {
    static let shared = DialService()

    private init() { }

    @discardableResult
    func dial(_ telUrl: URL) async throws -> Bool {
        guard await UIApplication.shared.canOpenURL(telUrl) else {
            throw DialingError.canNotDial
        }
        
        let isCompleted = await UIApplication.shared.open(telUrl)
        if !isCompleted { throw DialingError.canNotDial }
        return isCompleted
    }
}
