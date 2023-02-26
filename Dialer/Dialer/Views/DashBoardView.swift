//
//  DashBoardView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct DashBoardView: View {
    @EnvironmentObject private var data: MainViewModel

    @EnvironmentObject private var locationManager: LocationManager

    @AppStorage(UserDefaults.Keys.showWelcomeView)
    private var showWelcomeView: Bool = true
    @AppStorage(UserDefaults.Keys.allowBiometrics)
    @AppStorage(UserDefaults.Keys.lastUserLocation)
    private var lastUserLocation: UserLocation?
    private var allowBiometrics = false

    @State private var presentQuickDial = false
    @State private var presentSendingView = false
    @State private var showPurchaseSheet = false

    private let checkCellularProvider = CTCarrierDetector.shared.cellularProvider()
    
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
                            .onTapForBiometrics {
                                presentSendingView = $0
                            }
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
            .navigationTitle("Dialer")
            .overlay(content: {
                ZStack {
                    Color.black.opacity(0.4)
                    Text("\(locationManager.status.rawValue)")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
            })
            .onAppear(perform: {
                Task {
                    await locationManager.requestAuthorisation()
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if allowBiometrics {
                        gearGradient
                            .onTapForBiometrics {
                                if $0 {
                                    data.showSettingsView()
                                }
                            }
                    } else {
                        Button(action: data.showSettingsView) { gearGradient }
                    }
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

            Label {
                Text(LocalizedStringKey(checkCellularProvider.message))
                    .font(
                        .system(
                            .body,
                            design: .rounded)
                        .weight(.medium)
                    )
                    .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: checkCellularProvider.status ? "chart.bar.fill" : "chart.bar")
            }
            .foregroundColor(checkCellularProvider.status ? .main : .red)
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom,8)
    }
}

#if DEBUG
struct DashBoardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashBoardView()
                .environmentObject(MainViewModel())
                .environmentObject(LocationManager())
            //            .previewIn(.fr)
            //            .previewLayout(.sizeThatFits)
        }
    }
}
#endif
