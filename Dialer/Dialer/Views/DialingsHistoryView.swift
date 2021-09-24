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
            }
            .navigationTitle("History")
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Text("Total:")
                    Spacer()
                    Text("\(data.estimatedTotalPrice) RWF")
                }
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .opacity(0.9)
                .padding(8)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .truncationMode(.middle)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        data.showHistorySheet.toggle()
                    }
                }
            }
        }
    }
}

struct DialingsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DialingsHistoryView(data: MainViewModel())
    }
}
