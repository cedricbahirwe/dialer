//
//  ContactRowView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/06/2023.
//

import SwiftUI

struct ContactRowView: View {
    let contact: Contact
    var body: some View {
        HStack {
            Text(contact.names)
                .font(.system(.callout, design: .rounded).weight(.medium))
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if contact.phoneNumbers.count == 1 {
                    Text(contact.phoneNumbers[0])
                } else {
                    Text("\(Text(contact.phoneNumbers[0])), +\(contact.phoneNumbers.count-1)more")
                }
            }
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    ContactRowView(contact: MockPreviewData.contact1)
        .padding()
}
