//
//  InsightsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

@available(iOS 17.0, *)
struct InsightsView: View {
    @EnvironmentObject private var insightsStore: DialerInsightStore

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var total: Int {
        insightsStore.insights.map(\.totalAmount).reduce(0, +)
    }

    @State private var selectedInsight: ChartInsight?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {

                ZStack {
                    InsightsChartsView(insights: insightsStore.insights, total: total)
                        .animation(.smooth, value: insightsStore.selectedPeriod)
                        .aspectRatio(1, contentMode: .fit)

                    InsightsTotalView(
                        total: total,
                        periods: insightsStore.periods,
                        selectedPeriod: insightsStore.selectedPeriod,
                        onSelectePeriod: insightsStore.setFilterPeriod
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)

                HStack(spacing: 16) {
                    ForEach(insightsStore.periods, id: \.self) { period in
                        Button(period.capiltalized) {
                            insightsStore.setFilterPeriod(period)
                        }
                        .bold()
                        .foregroundStyle(period == insightsStore.selectedPeriod ? .primary : .secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Spending Categories")
                            .font(.system(.title3, design: .rounded, weight: .bold))

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(insightsStore.insights.sorted(by: { $0.totalAmount > $1.totalAmount })) { insight in
                                SpendingCategoryOverview(
                                    overview: insight,
                                    isSelected: selectedInsight?.id == insight.id,
                                    totalAmount: total
                                )
                                .onTapGesture {
                                    if selectedInsight?.id == insight.id {
                                        selectedInsight = nil
                                    } else {
                                        selectedInsight = insight
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background (
                    Color(.systemBackground)
                        .clipShape(.rect(topLeadingRadius: 30, topTrailingRadius: 30))
                        .shadow(color: .lightShadow, radius: 4, x: -4, y: -4)
                        .shadow(color: .darkShadow, radius: 4, x: 4, y: 4)
                        .ignoresSafeArea()
                )
            }
            .opacity(insightsStore.insights.isEmpty ? 0 : 1)
            .overlay {
                if insightsStore.insights.isEmpty {
                    ContentUnavailableView(
                        "No insights found yet.",
                        systemImage: "exclamationmark.circle",
                        description: Text("Make some transactions to see insights.")
                    )
                }
            }
        }
        .task {
            insightsStore.setFilterPeriod(.year)
            await insightsStore.getInsights()
        }
        .background(.offBackground)
        .sheet(item: $selectedInsight) { insight in
            InsightTransactionsView(
                store: InsightHistoryViewModel(insight: insight)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(30)
            .presentationContentInteraction(.scrolls)
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Insights")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
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
        .trackAppearance(.insights)
    }
}

@available(iOS 17.0, *)
#Preview {
    NavigationStack {
        InsightsView()
            .environmentObject(DialerInsightStore())
    }
    //        .preferredColorScheme(.dark)
}
