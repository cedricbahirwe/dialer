//
//  ComingSoonLabel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/12/2021.
//

import SwiftUI

struct ComingSoonLabel: View {
    var body: some View {
        Text("Coming soon")
            .font(.caption)
            .padding(8)
            .frame(height: 30)
            .background(Color.red.opacity(0.1))
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .foregroundColor(.red)
    }
}


struct ComingSoonLabel_Previews: PreviewProvider {
    static var previews: some View {
        ComingSoonLabel()
    }
}
