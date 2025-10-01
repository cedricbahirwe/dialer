//
//  CustomDialingModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import Foundation

struct CustomDialingModel: Identifiable {
    var id: UUID
    var editedCode: String
    var title: String

    init(editedCode: String = "", label: String = "") {
        self.id = UUID()
        self.editedCode = editedCode
        self.title = label
    }

    init(_ ussdCode: CustomUSSDCode) {
        self.id = ussdCode.id
        self.editedCode = ussdCode.ussd
        self.title = ussdCode.title
    }
}
