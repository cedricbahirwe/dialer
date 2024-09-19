//
//  TransactionHistoryRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/04/2021.
//

import SwiftUI

struct TransactionHistoryRow: View {
    let transaction: TransactionInsight
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                switch transaction.details {
                case .momo(let summary):
                    Text("\(transaction.type.formatted): \(Text(summary.number))")
                        .fontWeight(.medium)
                        .minimumScaleFactor(0.9)
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
                .fontDesign(.rounded)
                .fontWeight(.semibold)
        }
        .contentShape(Rectangle())
        .padding(4)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TransactionHistoryRow(
        transaction: MockPreviewData.clientInsight
    )
    .padding()
}
