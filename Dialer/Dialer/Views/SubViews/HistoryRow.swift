//
//  HistoryRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/04/2021.
//

import SwiftUI

struct HistoryRow: View {
    let recentCode: RecentDialCode
    var body: some View {
        HStack {
            if recentCode.count > 20 {
                Image(systemName: "flame.fill")
                    .foregroundColor(.red)
            } else {
                Circle()
                    .fill(getColor())
                    .frame(width: 12, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("You bought \(recentCode.detail.amount) RWF of airtime")
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.9)
                
                HStack {
                    if (0..<10).contains(recentCode.count) {
                        Text("^[\(recentCode.count) time](inflect: true)")
                    } else {
                        Text("More than 10+ times")
                            .italic()
                    }
                    Spacer()
                    Text(recentCode.detail.purchaseDate, style: .date)
                }
                .font(.footnote)
                .foregroundColor(.secondary)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .contentShape(Rectangle())
        .padding(4)
    }

    private func getColor() -> Color {  
        if recentCode.detail.amount < 500 {
            return .green
        } else if recentCode.detail.amount < 1000 {
            return .blue
        } else {
            return .red
        }
    }
}

#if DEBUG
struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(recentCode: MockPreview.recentDial)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
