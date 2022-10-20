//
//  AlertDialog.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 20/10/2022.
//

import SwiftUI

struct AlertDialog: Identifiable {
    init(id: UUID = UUID(), _ title: LocalizedStringKey? = nil, message: LocalizedStringKey, action: @escaping () -> Void) {
        self.id = id
        self.title = title
        self.message = message
        self.action = action
    }

    var id = UUID()
    var title: LocalizedStringKey?
    var message: LocalizedStringKey
    var action: () -> Void
}
