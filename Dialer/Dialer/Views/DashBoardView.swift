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
    @EnvironmentObject private var data: MainViewModel

    @Environment(\.colorScheme) private var colorScheme
    @State private var dragState: DragState = .closed
    @State private var presentQuickDial = false
    @State private var presentSendingView = false
    @State private var showPurchaseSheet = false
    @AppStorage(UserDefaults.Keys.showWelcomeView)
    private var showWelcomeView: Bool = true
    
    private let checkCellularProvider = CTCarrierDetector.shared.cellularProvider()
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let position = value.startLocation.y + value.translation.height
                dragState = .dragging(position: position)
            }
            .onEnded { value in
                let snapDistance = 600 * CGFloat(0.25)
                showPurchaseSheet = value.translation.height < snapDistance
                withAnimation {
                    dragState = showPurchaseSheet ? .open : .closed
                }
            }
    }
    
    var body: some View {

            ZStack(alignment: .bottom) {
                VStack {
                    VStack(spacing: 29) {
                        HStack(spacing: 20) {
                            DashItemView(
                                title: "Buy airtime",
                                icon: "wallet.pass")
                                .momoDisability()
                                .onTapGesture {
                                    withAnimation {
                                        showPurchaseSheet.toggle()
                                    }
                                }
                            
                            DashItemView(
                                title: "Transfer/Pay",
                                icon: "paperplane.circle")
                                .onChangeBiometrics(isActive: $presentSendingView)
                        }
                        
                        HStack(spacing: 15) {
                            DashItemView(
                                title: "History",
                                icon: "clock.arrow.circlepath")
                                .onTapGesture {
                                    data.showHistorySheet.toggle()
                                }
                            
                            NavigationLink {
                                MySpaceView()
                            } label: {
                                DashItemView(
                                    title: "My Space",
                                    icon: "person.crop.circle.badge")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                    }
                    .padding()
                    
                    NavigationLink(isActive: $presentSendingView) {
                        SendingView()
                    } label: { EmptyView() }
                    
                    Spacer()
                    
                    if checkCellularProvider.status == false {
                        HStack {
                            Text("Sim card is required to unlock all the features.")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThickMaterial)
                        .hidden()
                    }
                    
                    bottomBarView
                }
                .blur(radius: showPurchaseSheet ? 3 : 0)
                .allowsHitTesting(!showPurchaseSheet)

                if showPurchaseSheet {
                    Color.black.opacity(0.001)
                        .onTapGesture {
                            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8)) {
                                showPurchaseSheet = false
                            }
                        }
                }
                PurchaseDetailView(isPresented: $showPurchaseSheet, data: data)
            }
            .sheet(isPresented: showWelcomeView ? $showWelcomeView : data.settingsAndHistorySheetBinding()) {
                if showWelcomeView {
                    WhatsNewView(isPresented: $showWelcomeView)
                } else {
                    if data.showSettingsSheet {
                        SettingsView()
                            .environmentObject(data)
                    } else {
                        DialingsHistoryView(data: data)
                    }
                }
            }
            .fullScreenCover(isPresented: $presentQuickDial) {
                QuickDialingView()
            }
            .background(Color.primaryBackground)
            .navigationTitle("Dial It")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: data.showSettingsView) { gearGradient }
                }
                
            }
    }
    
    private var gearGradient: some View {
        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 30, height: 30)
            .mask(
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
    }
    
}

extension DashBoardView {
    var bottomBarView: some View {
        HStack {
            if UIApplication.hasSupportForUSSD {
                Button {
                    presentQuickDial.toggle()
                } label: {
                    Label("Quick Dial", systemImage: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.mainRed)
            }

            Spacer()

            HStack(spacing: 1) {
                Image(systemName: checkCellularProvider.status ? "chart.bar.fill" : "chart.bar")

                Text(NSLocalizedString(checkCellularProvider.message, comment: ""))
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
//            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

struct DashItemView: View {
    let title: LocalizedStringKey
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
                .frame(width: 25, height: 25)
                .mask(
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .background(Color.primaryBackground)
        .cornerRadius(15)
        .contentShape(Rectangle())
        .shadow(color: .lightShadow, radius: 4, x: -4, y: -4)
        .shadow(color: .darkShadow, radius: 4, x: 4, y: 4)

    }
}
