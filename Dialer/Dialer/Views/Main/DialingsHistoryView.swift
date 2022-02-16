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
                if let recentCodes = data.recentCodes, !recentCodes.isEmpty {
                    List {
                        ForEach(recentCodes) { recentCode in
                            HistoryRow(recentCode: recentCode)
                                .onTapGesture {
                                    data.performRecentDialing(for: recentCode)
                                }
                        }
                        .onDelete(perform: data.deleteRecentCode)
                    }
                } else {
                    
                    Spacer()
                    Text("No History Yet")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                    Text("Come back later.")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color.main)
                    Spacer()
                }

            }
            .navigationTitle("History")
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total:")
                        Spacer()
                        Text("\(data.estimatedTotalPrice) RWF")
                    }
                    Text("This estimation is based on the recent USSD codes used.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.system(size: 28, weight: .bold, design: .serif))
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
