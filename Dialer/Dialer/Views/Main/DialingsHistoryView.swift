//
//  DialingsHistoryView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 11/06/2021.
//

import SwiftUI

struct DialingsHistoryView: View {
    let data: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if data.recentCodes.isEmpty {
                        emptyHistoryView
                    } else {
                        List {
                            ForEach(data.recentCodes) { recentCode in
                                HistoryRow(recentCode: recentCode)
                                    .onTapGesture {
                                        Task {
                                            await data.performRecentDialing(for: recentCode)
                                        }
                                    }
                            }
                            .onDelete(perform: data.deletePastCode)
                        }
                    }
                }
            }
            .background(Color.primaryBackground)
            .navigationTitle("History")
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Total")
                        Text(":")
                        Spacer()
                        HStack(spacing: 3) {
                            Text("\(data.estimatedTotalPrice)")
                            Text("RWF")
                                .font(.system(size: 16, weight: .bold, design: .serif))
                        }
                    }
                    
                    Text("The estimations are based on the recent USSD codes used.")
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
                        dismiss()
                    }
                }
            }
            .trackAppearance(.history)
        }
    }
    
    private var emptyHistoryView: some View {
        Group {
            Spacer()
            Text("No History Yet")
                .font(.system(.title, design: .rounded).bold())
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            Text("Come back later.")
                .font(.system(.headline, design: .rounded))
            Spacer()
        }
    }
}

struct DialingsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DialingsHistoryView(data: HistoryViewModel())
    }
}
