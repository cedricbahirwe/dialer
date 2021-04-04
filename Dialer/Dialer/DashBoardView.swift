//
//  DashBoardView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI
class PurchaseViewModel: ObservableObject {
    @Published var composedCode: String = ""
}

struct DashBoardView: View {
    @State var isSearching = false
    @StateObject var data = PurchaseViewModel()
    var body: some View {
        NavigationView {
            VStack {
                headerView
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        DashItemView(
                            title: "Buy with Momo",
                            icon: "wallet.pass"
                        )
                        
                        DashItemView(
                            title: "Buy Directly",
                            icon: "speedometer"
                        )
                    }
                    
                    HStack(spacing: 15) {
                        DashItemView(
                            title: "All Options",
                            icon: "archivebox.circle.fill"
                        )
                        
                        DashItemView(
                            title: "History",
                            icon: "calendar.circle.fill"
                        )
                    }
                }
                .padding()
                
                Spacer()
                bottomBarView

            }
            .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}

struct DashBoardView_Previews: PreviewProvider {
    static var previews: some View {
        DashBoardView()
    }
}



struct DashItemView: View {
    let title: String
    let count: Int = 0
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack  {
                Image(systemName: icon)
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                Spacer()
                Text(count.description)
                    .fontWeight(.bold)
                    .font(.system(.title, design: .rounded))
                
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}


