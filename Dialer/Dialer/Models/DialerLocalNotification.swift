//
//  DialerLocalNotification.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/12/2022.
//

import SwiftUI

struct DialerLocalNotification: AppNotification {
    var id: UUID
    
    var title: String

    var message: String

    var info: [String : Any]
    
    var imageUrl: URL?

    var scheduledDate: Date
    
}
