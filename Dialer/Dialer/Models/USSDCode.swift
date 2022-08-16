//
//  USSDCode.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import Foundation

struct USSDCode: Identifiable, Hashable, Codable {
    static func == (lhs: USSDCode, rhs: USSDCode) -> Bool {
        lhs.ussd == rhs.ussd
    }

    public init(id: UUID = UUID(), title: String, ussd: String) throws {
        self.id = id
        self.title = title
        self.ussd = try Self.validateUSSD(from: ussd)
    }

    public let id: UUID
    public let title: String
    public let ussd: String

    static let example: USSDCode = try! USSDCode(title: "Check Airtime", ussd: "*131#")

    static let starSymbol: Character = "*"

    static let hashSymbol: Character = "#"
}

// MARK: Validation
extension USSDCode {
    enum USSDCodeValidationError: Error {
        case emptyUSSD
        case invalidFirstCharacter
        case invalidLastCharacter
        case invalidUSSD

//        localize

        var description: String {
            switch self {
            case .emptyUSSD:
                return "USSD code is empty."
            case .invalidFirstCharacter:
                return "USSD code should start with a * symbol."
            case .invalidLastCharacter:
                return "USSD code should end with a # symbol."
            case .invalidUSSD:
                return "Invalid USSD code, please check again your code."
            }
        }
    }

    private static func validateUSSD(from code: String) throws -> String {
        guard code.isEmpty == false else { throw USSDCodeValidationError.emptyUSSD }

        guard code.hasPrefix(String(starSymbol)) else { throw USSDCodeValidationError.invalidFirstCharacter }

        guard code.hasSuffix(String(hashSymbol)) else { throw USSDCodeValidationError.invalidLastCharacter }

        guard code.filter({ $0 == hashSymbol }).count == 1 else { throw USSDCodeValidationError.invalidUSSD }

        guard code.allSatisfy ({
            $0.isNumber || $0 == starSymbol || $0 == hashSymbol
        }) else { throw USSDCodeValidationError.invalidUSSD }

        return code
    }
}
