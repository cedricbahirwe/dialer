//
//  DashBoardView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI
class PurchaseViewModel: ObservableObject {
    @Published var composedCode: String = ""
    
    @Published var purchaseDetail = PurchaseDetailModel()
    
    @Published var showbottomSheet: Bool = false
    
    struct PurchaseDetailModel {
        var amount: String = ""
        var code: String = ""
        
        var fullCode: String {
            "*182*2*1*1*1*\(amount)*\(code)#"
        }
        

    }
    
    func confirmPurchase() {
        
        MainViewModel.dialCode(url: purchaseDetail.fullCode, completion: { result in
            switch result {
            case .success(let message):
                print("Message is", message)
            case .failure(let error):
                print(error.message)
            }
        })
    }
}


fileprivate enum DragState {
    case open
    case closed
    case dragging(position: CGFloat)
}
fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}
struct DashBoardView: View {
    @State var isSearching = false
    @StateObject var data = PurchaseViewModel()

    @State private var dragState: DragState = .closed

    private var dragGesture: some Gesture {
        DragGesture().onChanged { value in
            let position = value.startLocation.y + value.translation.height
            self.dragState = .dragging(position: position)
        }.onEnded { value in
            let snapDistance = 600 * Constants.snapRatio
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
                            .contentShape(Rectangle())
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
                                title: "History",
                                icon: "calendar.circle.fill"
                            )
                        }
                    }
                    .padding()
                    
                    Spacer()
                    bottomBarView

                }
                
                PurchaseDetailView(data: data)
                    .offset(y: data.showbottomSheet ? 0 : 605)
                    .gesture(self.dragGesture)
                    .animation(.interactiveSpring())
            
//                BottomSheetView(isOpen: $data.showbottomSheet, maxHeight: 600) {
//                    PurchaseDetailView(data: data)
//                        .offset(y: data.showbottomSheet ? 0 : 605)
//                        .gesture(self.dragGesture)
//                        .animation(.interactiveSpring())
//                }
//                .edgesIgnoringSafeArea(.all)
                
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


