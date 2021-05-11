//
//  DashBoardExtension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

extension DashBoardView {
    
    var bottomBarView: some View {
        HStack {
            Button {
                
            } label: {
                Label("New Dial", systemImage: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom,8)
    }
}
