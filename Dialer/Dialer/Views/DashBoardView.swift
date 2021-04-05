//
//  DashBoardView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

fileprivate enum DragState {
    case open
    case closed
    case dragging(position: CGFloat)
}

struct DashBoardView: View {
    @State var isSearching = false
    @EnvironmentObject var data: MainViewModel
    @Environment(\.scenePhase) var scenePhase

    @State private var dragState: DragState = .closed

    private var dragGesture: some Gesture {
        DragGesture().onChanged { value in
            let position = value.startLocation.y + value.translation.height
            self.dragState = .dragging(position: position)
        }.onEnded { value in
            let snapDistance = 600 * CGFloat(0.25)
            self.data.showbottomSheet = value.translation.height < snapDistance
            self.dragState = self.data.showbottomSheet ? .open : .closed
        }
    }
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    headerView
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            DashItemView(
                                title: "Buy with Momo",
                                icon: "wallet.pass"
                            )
                            .onTapGesture {
                                data.showbottomSheet.toggle()
                            }
                            
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
                                title: "Check Intenet Balance",
                                icon: "lock.shield"
                            )
                            .onTapGesture(perform: data.checkBalance)
                        }
                    }
                    .padding()
                    
                    if let codes = data.recentCodes, !codes.isEmpty  {
                        bottomSectionView

                    } else {
                        Spacer()
                    }
                    bottomBarView

                }
                
                PurchaseDetailView(data: data)
                    .offset(y: data.showbottomSheet ? 0 : 605)
                    .gesture(self.dragGesture)
                    .animation(.interactiveSpring())
                
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
            .environmentObject(MainViewModel())
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
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .contentShape(Rectangle())

    }
}


