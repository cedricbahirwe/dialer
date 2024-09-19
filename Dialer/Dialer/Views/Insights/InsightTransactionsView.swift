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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if store.insight.transactions.isEmpty {
                        emptyHistoryView
                    } else {
                        List {
                            ForEach(store.insight.transactions) { transaction in
                                TransactionHistoryRow(transaction: transaction)
                            }
                        }
                    }
                }
            }
//            .background(Color.primaryBackground)
//            .navigationTitle("History")
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total")
                        Text(":")
                        Spacer()
                        HStack(spacing: 3) {
                            Text("\(store.insight.totalAmount)")
                            Text("RWF")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                        }
                    }

                    Text("The estimations are based on the recent USSD codes used.")
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
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .trackAppearance(.insightTransaction)
        }
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
