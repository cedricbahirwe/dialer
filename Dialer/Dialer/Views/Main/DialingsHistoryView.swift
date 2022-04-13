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
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                    Text("Come back later.")
                        .font(.system(.headline, design: .rounded))
                    Spacer()
                }

            }
            .background(Color.primaryBackground)
            .navigationTitle("History")
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total:")
                        Spacer()
                        HStack(spacing: 3) {
                            Text("\(data.estimatedTotalPrice)")
                            Text("RWF")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                        }
                    }
                    Text("This estimation is based on the recent USSD codes used.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.system(size: 26, weight: .bold, design: .serif))
                .opacity(0.9)
                .padding(8)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .truncationMode(.middle)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
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
            .preferredColorScheme(.dark)
    }
}
