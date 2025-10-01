//
//  PhoneService.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 18/10/2023.
//

import UIKit

struct PhoneService {
    static let shared = PhoneService()

    private init() { }

    func dial(_ telUrl: URL) async throws {
        guard await UIApplication.shared.canOpenURL(telUrl) else {
            throw DialingError.canNotDial
        }

        guard await UIApplication.shared.open(telUrl) else {
            throw DialingError.canNotDial
        }
    }

    func getDialURL(from fullCode: String) throws -> URL {
        if let telUrl = URL(string: "tel://\(fullCode)") {
            return telUrl
        } else {
            throw DialingError.canNotDial
        }
    }
}
