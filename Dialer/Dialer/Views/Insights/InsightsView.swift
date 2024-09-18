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
    private var insights: [Insight] {
        if insightsStore.filteredInsightsByPeriod.isEmpty {
            []//Insight.examples[
        } else {
            Insight.makeInsights(insightsStore.filteredInsightsByPeriod)
        }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var total: Int {
        insights.map(\.totalAmount).reduce(0, +)
    }
    @State private var selectedInsight: Insight?

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                if #available(iOS 17.0, *) {
                    ZStack {
                        InsightsChartsView(insights: insights, total: total)
                            .animation(.smooth, value: insights)
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
//                            withAnimation {
                                insightsStore.setFilterPeriod(period)
//                            }
                        }
                        .bold()
                        .foregroundStyle(period == insightsStore.selectedPeriod ? .primary : .secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Spending Categories")
                            .font(.title3)
                            .fontDesign(.rounded)
                            .fontWeight(.bold)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(insights.sorted(by: { $0.totalAmount > $1.totalAmount })) { insight in
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
            .opacity(insights.isEmpty ? 0 : 1)
        }
        .task {
            await insightsStore.getInsights()
        }
        .background(.offBackground)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Insights \(insightsStore.filteredInsightsByPeriod.count)")
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

    struct Insight: Identifiable, Equatable {
        let id = UUID()
        private let name: RecordType

        var count: Int
        var totalAmount: Int

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
        static let examples = [
            Insight(name: .merchant, count: 47, totalAmount: 100),
            Insight(name: .user, count: 26, totalAmount: 200),
            Insight(name: .airtime, count: 19, totalAmount: 210),
            Insight(name: .other, count: 8, totalAmount: 110),
        ]

        static func makeInsights(_ insights: [TransactionInsight]) -> [Insight] {
            var insightsResult = [Insight]()

            for insight in insights {
                if let foundIndex = insightsResult.firstIndex(where: {
                    $0.name == insight.type
                }) {
                    insightsResult[foundIndex].count += 1
                    insightsResult[foundIndex].totalAmount += insight.amount
                } else {
                    let new = Insight(
                        name: insight.type,
                        count: 1,
                        totalAmount: insight.amount
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
