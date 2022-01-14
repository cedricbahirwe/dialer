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
    @State private var presentNewDial = false
    @State private var presentSendingView = false
    @State private var showPurchaseSheet = false
    
    private let checkCellularProvider = CTCarrierDetector.shared.cellularProvider()
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
                showPurchaseSheet = value.translation.height < snapDistance
                dragState = showPurchaseSheet ? .open : .closed
            }
    }
    
    var body: some View {

            ZStack(alignment: .bottom) {
                VStack {
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            DashItemView(
                                title: "Buy airtime",
                                icon: "wallet.pass")
                                .momoDisability()
                                .onTapGesture {
                                    showPurchaseSheet.toggle()
                                }
                            
                            DashItemView(
                                title: "Send/Pay",
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
                                UtilitiesView()
                            } label: {
                                DashItemView(
                                    title: "Utilities",
                                    icon: "wrench.and.screwdriver")
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
            .sheet(isPresented: data.settingsAndHistorySheetBinding()) {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
                
            }
    }
    
    private var settingsButton: Button<AnyView> {
        Button(action: data.showSettingsView) {
            AnyView(
            LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width: 30, height: 30)
                .mask(
                    Image(systemName: "gear")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
            )
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
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
}
