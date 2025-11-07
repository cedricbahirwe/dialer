//
//  MerchantCreationModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

struct MerchantCreationModel {
    var name = ""
    var code = ""
    var address = ""

    enum Error: Swift.Error {
        case invalidInput(String)
        var message: String {
            switch self {
            case .invalidInput(let msg): return msg
            }
        }
    }

    func getMerchant() throws -> Merchant {
        guard name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
        else { throw Error.invalidInput("Name should be more or equal to 3 characters") }
        guard (AppConstants.merchantDigitsRange).contains(code.count)
        else { throw Error.invalidInput("Code should be 5 to 7 digits")  }
        guard code.allSatisfy(\.isNumber)
        else { throw Error.invalidInput("Code contains only digits")  }

        let userId = DialerStorage.shared.getSavedDevice()?.deviceHash
        return Merchant(name: name, address: address.isEmpty ? nil : address, code: code, ownerId: userId)
    }
}
