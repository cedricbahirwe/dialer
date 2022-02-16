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
                Image(systemName: "phone.circle.fill")
                    .imageScale(.large)
                    .symbolRenderingMode(.multicolor)
                Text(recentCode.detail.fullCode)
                    .font(.title3)
                    .fontWeight(.semibold)
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
}

struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(recentCode: .example)
    }
}
