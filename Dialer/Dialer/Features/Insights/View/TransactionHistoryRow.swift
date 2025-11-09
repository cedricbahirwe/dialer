//
//  TransactionHistoryRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/04/2021.
//

import SwiftUI

struct TransactionHistoryRow: View {
    let transaction: TransactionInsight
    @StateObject private var phoneManager = PhoneContacts.shared

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                switch transaction.details {
                case .momo(let summary):
                    Group {
                        if let ownerName = phoneManager.getContactName(for: summary) {
                            Text("Sent to \(ownerName)")
                        } else {
                            Text("\(transaction.type.formatted): \(Text(summary.number))")
                        }
                    }
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                default:
                    Text(transaction.type.formatted)
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.9)
                }
                
                Text(transaction.createdDate, style: .date)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(transaction.amount, format: .currency(code: "RWF"))
                .font(.system(.body, design: .rounded, weight: .semibold))
        }
        .contentShape(Rectangle())
        .padding(4)
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    TransactionHistoryRow(
        transaction: MockPreviewData.clientInsight
    )
    .padding()
}
