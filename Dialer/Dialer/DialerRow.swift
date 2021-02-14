//
//  DialerRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI

struct DialerRow: View {
    let title: String
    let action: () -> ()
    let lineLimit: Int
    
    init(title: String, _ lineLimit: Int = 1, perfom: @escaping () -> () = { }) {
        self.title = title
        self.action = perfom
        self.lineLimit = lineLimit
    }
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                    .lineLimit(lineLimit)
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 8)
                    .padding(.leading)
                    .foregroundColor(Color(.label))

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
            Divider()
        }
    }
}
