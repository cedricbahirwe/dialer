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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var data: MainViewModel
    
    @State private var dragState: DragState = .closed
    @State private var presentNewDial: Bool = false
    @State private var offset: CGSize = .zero
    var bgColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let position = value.startLocation.y + value.translation.height
                dragState = .dragging(position: position)
            }
            .onEnded { value in
                let snapDistance = 600 * CGFloat(0.25)
                data.showbottomSheet = value.translation.height < snapDistance
                dragState = data.showbottomSheet ? .open : .closed
            }
    }
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Image("water")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.primary.opacity(0.2))
                    .gesture(
                        DragGesture()
                            .onChanged({ offset = $0.translation })
                            .onEnded({ _ in offset = .zero })
                    )
                    .offset(offset)
                    .animation(.interpolatingSpring(stiffness: 1, damping: 0.1))
                    .offset(x: 20)
                    .frame(maxHeight: .infinity)
                
                VStack {
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
                                title: "History",
                                icon: "timelapse"
                            )
                            .onTapGesture {
                                data.showHistorySheet.toggle()
                            }
                            
                            DashItemView(
                                title: "Check Intenet Balance",
                                icon: "lock.shield"
                            )
                            .onTapGesture(perform: data.checkBalance)
                        }
                    }
                    .padding()
                    Spacer()
                    bottomBarView
                }
                
                PurchaseDetailView(data: data)
            }
            
            .sheet(isPresented:presentNewDial ? $presentNewDial : $data.showHistorySheet) {
                if presentNewDial {
                    NewDialingView()
                } else {
                    HistoryView(data: data)
                }
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Dialer")
            .toolbar {
                
                if let _  = UserDefaults.standard.value(forKey: UserDefaults.Keys.PinCode) {
                    Text("Delete Pin")
                        .foregroundColor(.red)
                        .onTapGesture (perform: data.removePin)
                }
            }
        }
    }
}

extension DashBoardView {
    var bottomBarView: some View {
        HStack {
            Button {
                presentNewDial.toggle()
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
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                Spacer()
                Text(count.description)
                    .fontWeight(.bold)
                    .font(.system(.title, design: .rounded))
                    .hidden()
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
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .cornerRadius(12)
        .contentShape(Rectangle())
        
        
    }
}
