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
    struct Insight: Identifiable {
        let id = UUID()
        private let name: InsightType
        let count: Double
        let color: Color
        var title: String { name.rawValue.capitalized }
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
        static let examples = [
            Insight(name: .merchant, count: 47, color: Color.orange),
            Insight(name: .user, count: 26, color: Color.indigo),
            Insight(name: .airtime, count: 19, color: Color.blue),
            Insight(name: .other, count: 8, color: Color.red),
        ]

        enum InsightType: String {
            case merchant
            case user
            case airtime
            case other
        }
    }

    @Binding var isPresented: Bool
    @State private var insights: [Insight] = Insight.examples
    var total: Double {
        insights.map { $0.count }.reduce(0, +)
    }
    static let periods = ["Week", "Month", "Year"]
    @State private var selectedPeriod: String = periods[1]

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Good day, Driosman")
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
                            .annotation(position: .overlay, alignment: .center, overflowResolution: .automatic) {
                                Text((insight.count / total), format: .percent.precision(.fractionLength(0)))
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

                            Text((total*100).formatted(.currency(code: "RWF")))
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
                                SpendingCategoryOverview(overview: insight)
                            }
                        }
                    }
                    .padding(20)
                }
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
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    struct SpendingCategoryOverview: View {
        let overview: InsightsView.Insight
        var body: some View {
            VStack(alignment: .leading) {

                VStack(alignment: .leading) {
                    HStack {
                        Text((100*overview.count).formatted(.currency(code: "RWF")))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .minimumScaleFactor(0.75)
                        //                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Text(
                            (overview.count/100),
                            format: .percent.precision(.fractionLength(0))
                        )
                        .font(.caption)
                        .fontWeight(.semibold)
                    }

                    Text(overview.title)
                        .font(.callout)
                }

                overview.icon
                    .frame(width: 32, height: 32)
                    .background(overview.color, in: .circle)
                    .foregroundStyle(.white)

            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thickMaterial, in: .rect(cornerRadius: 26))
        }
    }
}

#Preview {
    InsightsView(isPresented: .constant(true))
    //        .preferredColorScheme(.dark)
}
