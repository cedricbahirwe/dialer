//
//  HistoryView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 29/04/2021.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var data: MainViewModel
    
    var body: some View {
        NavigationView {
            List {
                if let recentCodes = data.recentCodes, !recentCodes.isEmpty {
                    ForEach(recentCodes) { recentCode in
                        HistoryRow(recentCode: recentCode)
                            .onTapGesture {
                                data.performQuickDial(for: recentCode.detail.fullCode)
                            }
                    }
                    .onDelete(perform: data.deleteRecentCode)
                    
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text(data.estimatedTotalPurchasesPirce.description)
                    }
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .opacity(0.9)
                }
            }
            .navigationTitle("History")
            .onAppear() {
                print(data.recentCodes)
            }
        }
    }
    
    
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(MainViewModel())
    }
}

// Unused
//.contextMenu(ContextMenu(menuItems: {
//    Button {
//        data.deleteRecentCode(code: recentCode)
//    } label: {
//        Label("Delete", systemImage: "trash")
//    }
//
//    Button {
//        data.performQuickDial(for: recentCode.code)
//    } label: {
//        Label("Dial", systemImage: "phone.circle")
//    }
//}))
