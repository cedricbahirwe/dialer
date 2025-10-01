//
//  InsightsTotalView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 18/09/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct InsightsTotalView: View {
    let total: Int
    let periods: [InsightFilterPeriod]
    let selectedPeriod: InsightFilterPeriod
    var onSelectePeriod: (InsightFilterPeriod) -> Void
    var body: some View {
        VStack(spacing: 5) {
            Menu {
                ForEach(periods, id: \.self) { period in
                    Button(period.capitalized) {
                        onSelectePeriod(period)
                    }
                    .disabled(period == selectedPeriod)
                }
            } label: {
                HStack(spacing: 2) {
                    Text("Spent this **\(selectedPeriod.capitalized)**")
                    Image(systemName: "arrowtriangle.down.fill")
                }
            }
            .font(.caption)
            .foregroundStyle(.primary)

            Text(total, format: .currency(code: "RWF"))
                .font(.system(.title, design: .monospaced, weight: .bold))
                .lineLimit(3)
                .frame(maxWidth: 230)
                .multilineTextAlignment(.center)
        }
    }
}

//#Preview {
//    InsightsTotalView()
//}
