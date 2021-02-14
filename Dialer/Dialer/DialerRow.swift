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
    
    init(title: String, perfom: @escaping () -> () = { }) {
        self.title = title
        self.action = perfom
    }
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .foregroundColor(Color(.label))

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
            Divider()
        }
//        .buttonStyle(PlainButtonStyle())

    }
}
