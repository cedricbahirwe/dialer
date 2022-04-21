//
//  DialingsHistoryView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 11/06/2021.
//

import SwiftUI

struct DialingsHistoryView: View {
    @ObservedObject var data: MainViewModel
    @State private var didCopyToClipBoard: Bool = false
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if let recentCodes = data.recentCodes, !recentCodes.isEmpty {
                        List {
                            ForEach(recentCodes) { recentCode in
                                HistoryRow(recentCode: recentCode)
                                    .onTapGesture {
                                        data.performRecentDialing(for: recentCode)
                                        copyToClipBoard(recentCode)
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

                if didCopyToClipBoard {
                    Color.clear
                        .background(.ultraThinMaterial)
                    
                    VStack {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .padding(25)
                        
                        Text("USSD Code copied!")
                            .font(.headline)
                    }
                    .padding(20)
                    .frame(width: 200, height: 200)
                    .background(.thickMaterial)
                    .cornerRadius(15)
                    .transition(.scale)
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
                    Group {
                        if UIApplication.hasSupportForUSSD {
                            Text("These estimations are based on the recent USSD codes used.")
                        } else {
                            Text("These estimations are based on the recent USSD codes copied.")
                        }
                    }
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

    private func copyToClipBoard(_ recentCode: RecentCode) {
        let fullCode = data.getFullUSSDCode(from: recentCode.detail)
        UIPasteboard.general.string = fullCode
        withAnimation { didCopyToClipBoard = true }

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            withAnimation {
                didCopyToClipBoard = false
            }
        }
    }

}

struct DialingsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DialingsHistoryView(data: MainViewModel())
        //            .preferredColorScheme(.dark)
    }
}
