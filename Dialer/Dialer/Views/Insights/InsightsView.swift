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
        let title: String
        let count: Double
        let color: Color
        static let examples = [
            Insight(title: "Merchant", count: 150, color: Color.green),
            Insight(title: "User", count: 53, color: Color.blue),
            Insight(title: "Airtime", count: 34, color: Color.yellow),
            Insight(title: "Other", count: 13, color: Color.indigo),
        ]
    }
    @Binding var isPresented: Bool
    @State private var insights: [Insight] = Insight.examples
    var total: Double {
        insights.map { $0.count }.reduce(0, +)
      }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Good Going, Driosman")
                    .font(.title2.weight(.semibold))
                    .fontDesign(.rounded)

                HStack(spacing: 20) {
                    ZStack {
                        if #available(iOS 17.0, *) {
                            ZStack {
                                Chart(insights) { insight in
                                    SectorMark(
                                        angle: .value(
                                            Text(verbatim: insight.title),
                                            insight.count
                                        ),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(insight.color)
                                }
                                .chartLegend(.hidden)

                                Text(String(format: "%.0f", total))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.white)
                            }
                            .scaledToFit()
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(insights) { insight in
                            HStack {
                                Circle()
                                    .fill(insight.color)
                                    .frame(width: 10, height: 10)
                                Text(insight.title)
                                Spacer()
                                Text(insight.count, format: .number)
                            }
                            .fontDesign(.rounded)

                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                Color(red: 20/255, green: 96/255, blue: 122/255),
                in: .rect(cornerRadius: 30)
            )
            .foregroundStyle(.white)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    InsightsView(isPresented: .constant(true))
}
