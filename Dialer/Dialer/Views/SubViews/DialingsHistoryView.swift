//
//  DialingsHistoryView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 11/06/2021.
//

import SwiftUI

struct DialingsHistoryView: View {
    @ObservedObject var data: MainViewModel
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if let recentCodes = data.recentCodes, !recentCodes.isEmpty {
                        ForEach(recentCodes) { recentCode in
                            HistoryRow(recentCode: recentCode)
                                .onTapGesture {
                                    data.performRecentDialing(for: recentCode)
                                }
                        }
                        .onDelete(perform: data.deleteRecentCode)
                        
                    }
                }

                HStack {
                    Text("Total:")
                    Spacer()
                    Text("\(data.estimatedTotalPrice) RWF")
                }
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .opacity(0.9)
                .padding(8)
            }
            .navigationTitle("History")
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        data.showHistorySheet.toggle()
                    }
                }
            })
        }
    }
}

struct DialingsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DialingsHistoryView(data: MainViewModel())
    }
}
