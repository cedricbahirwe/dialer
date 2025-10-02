//
//  USSDCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

struct CustomUSSDCode: Identifiable, Equatable, Codable, Dialable {
    let id: UUID
    let title: String
    let ussd: String

    var fullUSSDCode: String { ussd }
    var isValid: Bool { true }

    init(id: UUID = UUID(), title: String, ussd: String) throws(ValidationError) {
        self.id = id
        guard !title.isEmpty else {
            throw ValidationError.emptyTitle
        }

        guard title.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 else {
            throw ValidationError.shortTitle
        }

        self.title = title
        self.ussd = try ValidationError.validateUSSDCode(ussd)
    }
}

extension CustomUSSDCode: Hashable {
    static func == (lhs: CustomUSSDCode, rhs: CustomUSSDCode) -> Bool {
        lhs.ussd == rhs.ussd || lhs.title == rhs.title
    }
}

// MARK: Validation
extension CustomUSSDCode {
    enum ValidationError: Error {
        private static let starSymbol: Character = "*"
        private static let hashSymbol: Character = "#"

        case emptyTitle
        case shortTitle
        case emptyUSSD
        case invalidFirstCharacter
        case invalidLastCharacter
        case invalidUSSD

        var description: String {
            switch self {
            case .emptyTitle:
                return "USSD name is Empty."
            case .shortTitle:
                return "USSD name should be at least 4 characters"
            case .emptyUSSD:
                return "USSD code is empty."
            case .invalidFirstCharacter:
                return "USSD code should start with a *."
            case .invalidLastCharacter:
                return "USSD code should end with a #."
            case .invalidUSSD:
                return "Invalid USSD code, please check again your code."
            }
        }

        static func validateUSSDCode(_ code: String) throws(ValidationError) -> String {
            guard code.isEmpty == false else { throw ValidationError.emptyUSSD }

            guard code.hasPrefix(String(starSymbol)) else { throw ValidationError.invalidFirstCharacter }

            guard !code.dropFirst(1).hasPrefix(String(starSymbol))
            else { throw ValidationError.invalidUSSD }

            guard code.hasSuffix(String(hashSymbol)) else { throw ValidationError.invalidLastCharacter }

            guard code.filter({ $0 == hashSymbol }).count == 1 else { throw ValidationError.invalidUSSD }

            guard code.allSatisfy ({
                $0.isNumber || $0 == starSymbol || $0 == hashSymbol
            }) else { throw ValidationError.invalidUSSD }

            return code
        }
    }
}
