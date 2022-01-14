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


struct BetaLabel: View {
    var body: some View {
        Text("Beta feature")
            .font(.caption)
            .padding(8)
            .frame(height: 30)
            .background(Color.green.opacity(0.1))
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .foregroundColor(.green)
    }
}

struct ComingSoonLabel_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComingSoonLabel()
            BetaLabel()
        }
        .padding()
        .previewLayout(.sizeThatFits)
        
    }
}
