//
//  AlertDialog.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 20/10/2022.
//

import SwiftUI

struct AlertDialog: Identifiable {
    init(id: UUID = UUID(), _ title: String? = nil, message: String, action: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.message = message
        self.action = action
    }

    let id: UUID
    let title: String?
    let message: String
    let action: () -> Void
}
