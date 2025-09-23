//
//  InsightTransactionsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct InsightTransactionsView: View {
    @ObservedObject var store: InsightHistoryViewModel

    var body: some View {
        VStack {
            if store.insight.transactions.isEmpty {
                emptyHistoryView
            } else {
                List {
                    ForEach(store.insight.transactions) { transaction in
                        TransactionHistoryRow(transaction: transaction)
                            .listRowBackground(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: store.insight.transactions.first?.id == transaction.id ? 15 : 0,
                                    bottomLeadingRadius: store.insight.transactions.last?.id == transaction.id ? 15 : 0,
                                    bottomTrailingRadius: store.insight.transactions.last?.id == transaction.id ? 15 : 0,
                                    topTrailingRadius: store.insight.transactions.first?.id == transaction.id ? 15 : 0
                                )
                                .foregroundStyle(.thickMaterial)
                                .opacity(0.5)
                            )
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            TotalEstimationView(total: store.insight.totalAmount)
        }
        .trackAppearance(.insightTransaction)
    }
    
    private var emptyHistoryView: some View {
        Group {
            Spacer()
            Text("No History Yet")
                .font(.system(.title, design: .rounded).bold())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            Text("Come back later.")
                .font(.system(.headline, design: .rounded))
            Spacer()
        }
    }
}

//#Preview {
//    InsightTransactionsView(
//        store: InsightHistoryViewModel(
//            insight: MockPreviewData.insight
//        )
//    )
//}

struct TotalEstimationView: View {
    let total: Int
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total :")
                Spacer()
                HStack(spacing: 3) {
                    Text("\(total)")
                    Text("RWF")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                }
            }

            Text("This is an estimate, and might differ from the actual amount.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 26, weight: .bold, design: .serif))
        .opacity(0.9)
        .padding(8)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .truncationMode(.middle)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
    }
}
