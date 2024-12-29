//
//  DialingsHistoryView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/10/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import Foundation
import SwiftUI

struct DialingsHistoryView: View {
    @EnvironmentObject private var insightsStore: DialerInsightStore
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var total: Int {
        insightsStore.chartInsights.map(\.totalAmount).reduce(0, +)
    }

    @State private var selectedInsight: ChartInsight?

    private var insights: [TransactionInsight] {
        if let selectedInsight {
            selectedInsight.transactions
        } else {
            insightsStore.transactionInsights
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {

                Section {
                    ForEach(insights) { transaction in
                        TransactionHistoryRow(transaction: transaction)
                            .padding(8)
                            .background(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: insights.first?.id == transaction.id ? 15 : 0,
                                    bottomLeadingRadius: insights.last?.id == transaction.id ? 15 : 0,
                                    bottomTrailingRadius: insights.last?.id == transaction.id ? 15 : 0,
                                    topTrailingRadius: insights.first?.id == transaction.id ? 15 : 0
                                )
                                .foregroundStyle(.thickMaterial)
                            )
                        if transaction.id != insights.last?.id {
                            Divider()
                        }
                    }
                    .padding(.horizontal)

                } header: {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(insightsStore.chartInsights.sorted(by: { $0.totalAmount > $1.totalAmount })) { insight in
                            SpendingCategoryOverview(
                                overview: insight,
                                isSelected: selectedInsight?.id == insight.id,
                                totalAmount: total
                            )
                            .background(.thickMaterial, in: .rect(cornerRadius: 20))
                            .onTapGesture {
                                withAnimation {
                                    if selectedInsight?.id == insight.id {
                                        selectedInsight = nil
                                    } else {
                                        selectedInsight = insight
                                    }
                                }
                            }
                        }

                    }
                    .padding()
                    .background(Color.primaryBackground)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .toolbarBackground(Material.ultraThin, for: .navigationBar)
        .background(Color.primaryBackground)
        .overlay {
            if insightsStore.transactionInsights.isEmpty {
                emptyHistoryView
            }
        }
        .task {
            await insightsStore.getInsights()
        }
        .safeAreaInset(edge: .bottom) {
            TotalEstimationView(total: insightsStore.generalTotal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("History")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }

            ToolbarItem(placement: .topBarTrailing) {
                if insightsStore.isFetching {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Button("Refresh") {
                        Task {
                            await insightsStore.getInsights()
                        }
                    }
                }
            }
        }
        .trackAppearance(.history)
    }

    private var emptyHistoryView: some View {
        VStack {
            Spacer()
            Text("No History Yet")
                .font(.system(.title, design: .rounded).bold())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            Text("Make some transactions to see the history.")
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

#Preview {
    DialingsHistoryView()
}
