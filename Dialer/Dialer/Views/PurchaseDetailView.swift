//
//  PurchaseDetailView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/04/2021.
//

import SwiftUI

struct PurchaseDetailView: View {
    @ObservedObject var data: MainViewModel
    private enum Field {
        case amount, code, none
    }
    @State private var edition: Field = .amount
    
    @State private var fieldValue: String = ""
    
    
    private var validCode: Bool {
        !data.purchaseDetail.code.isEmpty
    }
    
    private var validAmount: Bool {
        !data.purchaseDetail.amount.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 15) {
                Text(validAmount ? data.purchaseDetail.amount.description : "Enter Amount")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.primary.opacity(0.06))
                    .background(
                        Color.green.opacity(edition == .amount ? 0.04 : 0)
                    )
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation {
                            edition = .amount
                        }
                    }
                
                if data.pinCode != nil {
                    HStack(spacing: 0) {
                        Text(validCode ? data.purchaseDetail.code.description : "Enter Code")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .offset(x: data.pinCode == nil ? 30 : 0)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    edition = .code
                                }
                            }
                        Button(action: data.savePinCode, label: {
                            Text("Save")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 60, height: 40)
                                .background(Color.primary)
                                .cornerRadius(8)
                                .foregroundColor(Color(.systemBackground))
                        })
                        .disabled(data.purchaseDetail.code.count != 5)
                        .opacity(data.purchaseDetail.code.count == 5 ? 1 : 0.4)
                    }
                    .background(Color.primary.opacity(0.06))
                    .background(
                        Color.green.opacity(edition == .code ? 0.04 : 0.0)
                    )
                    .cornerRadius(8)
                } else {
                    Text("We've got your back 🎉\n Enter the amount and we'll take care of the rest✌🏾")
                        .foregroundColor(.green)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                }
                
                Button {
                    edition = .none
                    data.confirmPurchase()
                    
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.primary)
                        .cornerRadius(8)
                        .foregroundColor(Color(.systemBackground))
                }
                .disabled(!validCode && !validAmount)
            }
            
            PinView(input: storeInput())
                .padding(.bottom, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        .offset(y: 15)
        .font(.system(size: 18, weight: .semibold, design: .rounded))
    }
    
    private func storeInput() -> Binding<String>{
        switch edition {
        case .amount:
            return $data.purchaseDetail.amount
        case .code:
            return $data.purchaseDetail.code
        default:
            return .constant("")
        }
    }
}

struct PurchaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                Spacer()
                    .background(Color.red)
                PurchaseDetailView(data: MainViewModel())
            }
        }
    }
}

struct PinView: View {
    private let buttons: [String] = [ "1","2","3","4","5","6","7","8","9","*","0","X"
    ]
    
    @Binding var input: String // = ""
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.fixed(90)),
            GridItem(.fixed(90)),
            GridItem(.fixed(90)),
        ], spacing: 10) {
            ForEach(buttons, id: \.self) { button in
                Button {
                    if button == "X" {
                        if !input.isEmpty {
                            input.removeLast()
                        }
                    } else {
                        input.append(button)
                    }
                } label: {
                    Text(button)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .foregroundColor(
                    button == "X" ?
                        Color.red :
                        Color(.label)
                )
                
            }
        }
    }
}

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

fileprivate enum DragState {
    case open
    case closed
    case dragging(position: CGFloat)
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    @State private var dragState: DragState = .closed
    
    private var offsetY: CGFloat {
        switch dragState {
        case .open: return 0
        case .closed: return maxHeight - minHeight
        case let .dragging(position):
            return min(max(position, 0), maxHeight - minHeight)
        }
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
            )
    }
    
    private var dragGesture: some Gesture {
        DragGesture().onChanged { value in
            let position = value.startLocation.y + value.translation.height
            self.dragState = .dragging(position: position)
        }.onEnded { value in
            let snapDistance = self.maxHeight * Constants.snapRatio
            self.isOpen = value.translation.height < snapDistance
            self.dragState = self.isOpen ? .open : .closed
        }
    }
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = 0 //maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
        self.dragState = isOpen.wrappedValue ? .open : .closed
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Spacer()
                .layoutPriority(1.0)
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .background(Color(.systemBackground))
            .frame(height: self.maxHeight)
            .cornerRadius(Constants.radius)
            .offset(y: self.offsetY)
            .gesture(self.dragGesture)
            .animation(.interactiveSpring())
        }
    }
}

//struct BottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomSheetView(isOpen: .constant(true), maxHeight: 600) {
//            PurchaseDetailView(data: PurchaseViewModel())
//        }.edgesIgnoringSafeArea(.all)
//    }
//}
