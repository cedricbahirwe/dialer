//
//  InsightsChartsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 18/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI
import Charts

struct InsightsChartsView: View {

    let insights: [InsightsView.Insight]
    let total: Int

    var body: some View {

        Chart(insights) { insight in
            SectorMark(
                angle: .value(
                    Text(verbatim: insight.title),
                    insight.totalAmount
                ),
                innerRadius: .ratio(0.8),
//                outerRadius: .inset(0),
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
                .padding(.vertical, 5)
                .background(.thinMaterial, in: .capsule)
                .offset(x: 10, y: -10)
            }
        }
        .chartLegend(.hidden)
    }
}

//#Preview {
//    InsightsChartsView()
//}
