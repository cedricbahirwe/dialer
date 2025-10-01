//
//  USSDCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

struct USSDCode: Identifiable, Equatable, Codable, Dialable {
    private static let starSymbol: Character = "*"
    private static let hashSymbol: Character = "#"

    static func == (lhs: USSDCode, rhs: USSDCode) -> Bool {
        lhs.ussd == rhs.ussd || lhs.title == rhs.title
    }

    init(id: UUID = UUID(), title: String, ussd: String) throws {
        self.id = id
        guard !title.isEmpty else {
            throw USSDCodeValidationError.emptyTitle
        }

        guard title.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 else {
            throw USSDCodeValidationError.shortTitle
        }

        self.title = title
        self.ussd = try Self.validateUSSD(from: ussd)
    }

    let id: UUID
    let title: String
    let ussd: String

    var fullUSSDCode: String { ussd }
    var isValid: Bool { true }
}

// MARK: Validation
extension USSDCode {
    enum USSDCodeValidationError: Error {
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
    }

    private static func validateUSSD(from code: String) throws -> String {
        guard code.isEmpty == false else { throw USSDCodeValidationError.emptyUSSD }

        guard code.hasPrefix(String(starSymbol)) else { throw USSDCodeValidationError.invalidFirstCharacter }

        guard !code.dropFirst(1).hasPrefix(String(starSymbol))
        else { throw USSDCodeValidationError.invalidUSSD }

        guard code.hasSuffix(String(hashSymbol)) else { throw USSDCodeValidationError.invalidLastCharacter }

        guard code.filter({ $0 == hashSymbol }).count == 1 else { throw USSDCodeValidationError.invalidUSSD }

        guard code.allSatisfy ({
            $0.isNumber || $0 == starSymbol || $0 == hashSymbol
        }) else { throw USSDCodeValidationError.invalidUSSD }

        return code
    }
}
