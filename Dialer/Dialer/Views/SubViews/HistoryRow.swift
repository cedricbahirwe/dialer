//
//  HistoryRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/04/2021.
//

import SwiftUI

struct HistoryRow: View {
    let recentCode: RecentCode
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(getColor())
                    .frame(width: 10, height: 10)

                Text(recentCode.detail.fullCode)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                Image(systemName:
                        recentCode.count > 50 ?
                        "flame.fill" :
                        "\(recentCode.count).circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(recentCode.count > 50 ? .red : .primary)
            }
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 5)
    }

    private func getColor() -> Color {  
        if recentCode.detail.amount < 1000 {
            return .green
        } else if recentCode.detail.amount < 5000 {
            return .blue
        } else {
            return .red
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(recentCode: .example)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
