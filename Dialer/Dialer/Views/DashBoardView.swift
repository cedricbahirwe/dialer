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
                data.showPurchaseSheet = value.translation.height < snapDistance
                dragState = data.showPurchaseSheet ? .open : .closed
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            DashItemView(
                                title: "Buy with Momo",
                                icon: "wallet.pass")
                                .momoDisability()
                                .onTapGesture {
                                    data.showPurchaseSheet.toggle()
                                }
                            
                            NavigationLink(
                                destination: SendingView()) {
                                DashItemView(
                                    title: "Send with Momo",
                                    icon: "paperplane.circle")
                            }
                            .momoDisability()
                        }
                        
                        HStack(spacing: 15) {
                            DashItemView(
                                title: "History",
                                icon: "clock.arrow.circlepath")
                                .onTapGesture { 
                                    data.showHistorySheet.toggle()
                                }
                            
                            DashItemView(
                                title: "Insights",
                                icon: "lightbulb")
                                .onTapGesture(perform: data.checkInternetBalance)
                        }
                        .momoDisability()
                    }
                    .padding()
                    Spacer()
                    bottomBarView
                }
                .blur(radius: data.showPurchaseSheet ? 3 : 0)
                .allowsHitTesting(!data.showPurchaseSheet)
                
                PurchaseDetailView(data: data)
            }
            .sheet(isPresented: data.showSettingsSheet ? $data.showSettingsSheet : $data.showHistorySheet) {
                if data.showSettingsSheet {
                    SettingsView()
                        .environmentObject(data)
                } else {
                    DialingsHistoryView(data: data)
                }
            }
            .fullScreenCover(isPresented: $presentNewDial) {
                NewDialingView()
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Dialer")
            .toolbar {
                settingsButton
                
                    .onTapGesture  {
                        data.showSettingsSheet.toggle()
                    }
            }
        }
        .onAppear(perform: setupAppearance)
    }
    
    private var settingsButton: some View {
        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 25, height: 25)
            .mask(
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
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
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
            }
            .foregroundColor(checkCellularProvider.status ? .main : .red)
            .padding(.horizontal, 12)
            .frame(height: 35)
            .background(Color.white)
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
                LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
                    .frame(width: 25, height: 25)
                    .mask(
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    )
                Spacer()
                
                Text(count.description)
                    .fontWeight(.bold)
                    .font(.system(.title, design: .rounded))
                    .hidden()
            }
            
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
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
