//
//  InsightsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 15/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var insightsStore: DialerInsightStore
    @Binding var isPresented: Bool
    private var insights: [Insight] {
        if insightsStore.insights.isEmpty {
            Insight.examples
        } else {
            Insight.makeInsights(insightsStore.insights)
        }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var total: Int {
        insights.map { $0.totalAmount  }.reduce(0, +)
    }
    static let periods = ["Week", "Month", "Year"]
    @State private var selectedPeriod: String = periods[1]

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Good day, Driosman \(insightsStore.insights.count)")
                    .font(.title2.weight(.semibold))
                    .fontDesign(.rounded)
                    .padding([.horizontal, .top])
                if #available(iOS 17.0, *) {
                    ZStack {
                        Chart(insights) { insight in
                            SectorMark(
                                angle: .value(
                                    Text(verbatim: insight.title),
                                    insight.count
                                ),
                                innerRadius: .ratio(0.8),
                                angularInset: 4
                            )
                            .foregroundStyle(insight.color)
                            .cornerRadius(15)
                            .shadow(color: insight.color, radius: 3)
                            .annotation(
                                position: .overlay,
                                alignment: .center,
                                overflowResolution: .automatic
                            ) {
                                Text(
                                    Double(insight.totalAmount) / Double(total),
                                    format: .percent.precision(.fractionLength(1))
                                )
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(.thinMaterial, in: .capsule)
                            }
                        }
                        .chartLegend(.hidden)


                        VStack(spacing: 5) {
                            Menu {
                                ForEach(Self.periods, id: \.self) { period in
                                    Button(period) {
                                        selectedPeriod = period
                                    }
                                    .disabled(period == selectedPeriod)
                                }
                            } label: {
                                HStack(spacing: 2) {
                                    Text("Spent this **\(selectedPeriod)**")
                                    Image(systemName: "arrowtriangle.down.fill")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.primary)

                            Text(total, format: .currency(code: "RWF"))
                                .font(.title)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 16) {
                    ForEach(Self.periods, id: \.self) { period in
                        Button(period) {
                            selectedPeriod = period
                        }
                        .bold()
                        .foregroundStyle(period == selectedPeriod ? .primary : .secondary)

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
                            ForEach(insights) { insight in
                                SpendingCategoryOverview(overview: insight, totalAmount: total)
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

        }
        .task {
            await insightsStore.getInsights()
        }
    }

    struct SpendingCategoryOverview: View {
        let overview: InsightsView.Insight
        let totalAmount: Int
        var body: some View {
            VStack(alignment: .leading) {

                VStack(alignment: .leading) {
                    HStack {
                        Text(overview.totalAmount, format: .currency(code: "RWF"))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .minimumScaleFactor(0.75)
                        //                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Text(
                        Double(overview.totalAmount)/Double(totalAmount),
                            format: .percent.precision(.fractionLength(1))
                        )
                        .font(.caption)
                        .fontWeight(.semibold)
                    }

                    Text(overview.title)
                        .font(.callout)
                        .fontDesign(.rounded)
                }

                overview.icon
                    .frame(width: 32, height: 32)
                    .background(overview.color, in: .circle)
                    .foregroundStyle(.white)

            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: .rect(cornerRadius: 28))
        }
    }

    struct Insight: Identifiable {
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
    InsightsView(isPresented: .constant(true))
        .environmentObject(DialerInsightStore())
    //        .preferredColorScheme(.dark)
}
