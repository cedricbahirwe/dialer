//
//  InsightsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct InsightsView: View {
    @Binding var isPresented: Bool

    @EnvironmentObject private var insightsStore: DialerInsightStore

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var total: Int {
        insightsStore.insights.map(\.totalAmount).reduce(0, +)
    }

    @State private var selectedInsight: Insight?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                if #available(iOS 17.0, *) {
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
                }

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
                            .font(.title3.bold())
                            .fontDesign(.rounded)


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
                    //                        .shadow(color: .darkShadow, radius: 5)
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
            await insightsStore.getInsights()
        }
        .background(.offBackground)
        .sheet(item: $selectedInsight) { insight in
            InsightTransactionsView(
                store: InsightHistoryViewModel(insight: insight)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .presentationCornerRadius(30)
            .presentationContentInteraction(.scrolls)
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Insights")
                    .font(.title2.weight(.semibold))
                    .fontDesign(.rounded)
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

    struct Insight: Identifiable {
        let id: String?
        private let name: RecordType
        var transactions: [TransactionInsight]

        var count: Int {
            transactions.count
        }

        var totalAmount: Int {
            transactions.map(\.amount).reduce(0, +)
        }

        var title: String {
            name.rawValue.capitalized
        }

        var icon: Image {
            switch name {
            case .merchant:
                Image(systemName: "storefront")
            case .user:
                Image(systemName: "person.fill")
            case .airtime:
                Image(systemName: "simcard")
            case .other:
                Image(systemName: "ellipsis")
            }
        }
        var color: Color {
            switch name {
            case .merchant: .orange
            case .user: .indigo
            case .airtime: .blue
            case .other: .red
            }
        }

        static func makeInsights(_ transactions: [TransactionInsight]) -> [Insight] {
            var insightsResult = [Insight]()

            for transaction in transactions {
                if let foundIndex = insightsResult.firstIndex(where: {
                    $0.name == transaction.type
                }) {
                    insightsResult[foundIndex].transactions.append(transaction)
                } else {
                    let new = Insight(
                        id: transaction.id,
                        name: transaction.type,
                        transactions: [transaction]
                    )
                    insightsResult.append(new)
                }

            }

            return insightsResult
        }

    }
}

#Preview {
    NavigationStack {
        InsightsView(isPresented: .constant(true))
            .environmentObject(DialerInsightStore())
    }
    //        .preferredColorScheme(.dark)
}
