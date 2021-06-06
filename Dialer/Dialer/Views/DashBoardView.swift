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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var data: MainViewModel
    @State private var dragState: DragState = .closed
    @State private var presentNewDial: Bool = false
    
    private let checkCellularProvider = CTCarrierDetector.shared.checkCellularProvider()
    private var bgColor: Color {
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
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Image("water")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.primary.opacity(0.2))
                    .offset(x: 160, y: 200)
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
                            .momoDisability()
                            
                            DashItemView(
                                title: "Buy Directly",
                                icon: "speedometer"
                            )
                            .onTapGesture {
                                presentNewDial.toggle()
                            }
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
                            .onTapGesture(perform: data.checkInternetBalance)
                        }
                        .momoDisability()
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
        .onAppear(perform: setupAppearance)
    }
    private func setupAppearance() {
        
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withSymbolicTraits(.traitBold)?.withDesign(UIFontDescriptor.SystemDesign.rounded)
        let descriptor2 = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withSymbolicTraits(.traitBold)?.withDesign(UIFontDescriptor.SystemDesign.rounded)
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.font:UIFont.init(descriptor: descriptor2!, size: 34),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font:UIFont.init(descriptor: descriptor!, size: 17),
            NSAttributedString.Key.foregroundColor: UIColor.label
        ]
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
            
            HStack(spacing: 1) {
                Image(systemName: checkCellularProvider.status ? "chart.bar.fill" : "chart.bar")

                Text(checkCellularProvider.message)
            }
            .foregroundColor(checkCellularProvider.status ? .green : .red)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Color.primary)
            .cornerRadius(5)
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
