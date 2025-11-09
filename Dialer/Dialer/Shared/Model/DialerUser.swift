//
//  DialerUser.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 03/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct DialerUser: Codable {
    @DocumentID private var id: String?

    let username: String
    let device: DeviceAccount


    init(id: String? = nil, username: String, device: DeviceAccount) {
        self._id = DocumentID(wrappedValue: id)
        self.username = username
        self.device = device
    }
}
