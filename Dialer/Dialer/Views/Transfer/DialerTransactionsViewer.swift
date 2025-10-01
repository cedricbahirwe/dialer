//
//  DialerTransactionsViewer.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct DialerTransactionsViewer: View {
    var fees: (savings: Int, originalFee: Int, optimizedFee: Int)
    var transactions: [Transaction.Model]
    var onDial: ((Transaction.Model) async -> Void)

    @State private var currentOP = 0
    @State private var showDetails: Bool = true
    var isCompleted: Bool {
        currentOP == transactions.count
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 10) {
            Text("Save \(fees.savings.formatted(.currency(code: "RWF")))")
                .foregroundStyle(smartGradient)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .padding(.bottom, -12)

            HStack(alignment: .lastTextBaseline) {
                Text(fees.originalFee.formatted(.currency(code: "RWF")))
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(.secondary)
                    .strikethrough()

                Text(fees.optimizedFee.formatted(.currency(code: "RWF")))
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }


            HStack {
                DisclosureGroup(isExpanded: $showDetails) {
                    VStack(alignment: .leading) {
                        ForEach(0..<transactions.count, id: \.self) { i in
                            let transaction = transactions[i]
                            HStack {
                                Image(systemName: (currentOP > i)  ? "checkmark.circle.fill" : "checkmark.circle")
                                    .foregroundStyle(smartGradient)

                                Text("\(transaction.doubleAmount.formatted(.currency(code: "RWF")))")
                                    .font(.headline.weight(.medium))
                                Spacer()
                                Text("Fee: \(transaction.estimatedFee!.formatted(.currency(code: "RWF")))")
                                    .foregroundStyle(.secondary)
                            }
                            .strikethrough(currentOP > i)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                } label: {
                    Text("\(transactions.count) total transactions")
                        .font(.title2)
                        .foregroundStyle(.foreground)
                }
            }

            Button {
                if isCompleted {
                    dismiss()
                } else {
                    Task {
                        await onDial(transactions[currentOP])
                        currentOP += 1
                    }
                }
            } label: {
                HStack {
                    Text(isCompleted ? "Complete" : "Confirm \(currentOP+1) out of \(transactions.count)")

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.large)
                    }
                }
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor, in: .rect(cornerRadius: 10))
                .foregroundStyle(Color.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            Text("Dialer Splits")
                .bold()
                .foregroundStyle(smartGradient)
                .padding()
        }
        .background(ignoresSafeAreaEdges: .all)
    }
}


@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 400, height: 500)) {
    DialerTransactionsViewer(
        fees: (40, 100, 60),
        transactions: [
            .init(amount: "100", number: "07826298951", type: .client, isOptimized: true),
            .init(amount: "100", number: "07826298951", type: .client, isOptimized: true),
            .init(amount: "100", number: "07826298951", type: .client, isOptimized: true)
        ],
        onDial: {_ in })
}
