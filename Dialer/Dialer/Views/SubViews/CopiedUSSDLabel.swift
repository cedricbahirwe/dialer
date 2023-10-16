//
//  CopiedUSSDLabel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 22/04/2022.
//

import SwiftUI

struct CopiedUSSDLabel: View {
    var body: some View {
        Text("USSD Code copied!")
            .font(.system(.callout, design: .rounded))
            .foregroundColor(Color(.systemBackground))
            .padding(8)
            .background(Color.primary.opacity(0.75))
            .cornerRadius(5)
            .transition(.scale)
    }
}
