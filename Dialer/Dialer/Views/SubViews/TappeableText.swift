//
//  TappeableText.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/01/2022.
//

import SwiftUI

struct TappeableText: View {
    init(_ title: String, onTap action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    let title: String
    var action: () -> Void
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}
