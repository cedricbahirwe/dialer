//
//  HistoryRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/04/2021.
//

import SwiftUI

struct HistoryRow: View {
    let recentCode: MainViewModel.RecentCode
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "chevron.left.slash.chevron.right")
                    .imageScale(.small)
                    .frame(width: 30, height: 30)
                    .background(Color.black)
                    .clipShape(Circle())
                    .foregroundColor(.white)
                Text(recentCode.detail.fullCode)
                    .foregroundColor(Color(.label))
                    .fontWeight(.semibold)
                Spacer()
                Text(recentCode.count.description)
                    .foregroundColor(.gray)
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
