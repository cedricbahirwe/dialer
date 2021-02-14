//
//  HomeView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI
import Combine


struct HomeView: View {
    
    @State private var bottomTextFieldPadding: CGFloat = .zero
    @EnvironmentObject var mainVM: MainViewModel
    
    @State private var showPinView = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack (spacing: 0){
                    HStack {
                        Text("Dialers📞📱☎️")
                            .font(.system(size: 35, weight: .bold))
                        Spacer()
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            DialerRow(title: "Buy Internet Bundle ⏰")
                            DialerRow(title: "Buy Call Packs 📞")
                            DialerRow(title: "Buy with Mobile Money 💰")
                            DialerRow(title: "Settings ⚙️")
                            DialerRow(title: "Check Airtime Balance ⚖️", perfom: mainVM.dial)
                            DialerRow(title: "Check Mobile Money Balance ⚖️💲") {
                                showPinView.toggle()
                                mainVM.selectedDialer = .momo(option: .balance)
                            }
                        }
                    }
                    .resignKeyboardOnDragGesture()
                    .onReceive(Publishers.keyboardHeight, perform: { value in
                        withAnimation(Animation.easeIn(duration: 0.16)) {
                            self.bottomTextFieldPadding = abs(value)
                        }
                    })
                    
                }
                
                if showPinView == false {
                    VStack {
                        Spacer()
                        VStack(spacing: 0){
                            if mainVM.error.state {
                                Text(mainVM.error.message)
                                    .foregroundColor(.red)
                            }
                            HStack {
                                TextField("Enter Your Code", text: $mainVM.selectedCode)
                                    .foregroundColor(Color.white)
                                    .padding(.leading)
                                    .frame(height: 36)
                                    .background(Color.white.opacity(0.2).cornerRadius(5))
                                    .keyboardType(.phonePad)
                                
                                Button(action: mainVM.dial) {
                                    Text("Dial")
                                        .foregroundColor(.white)
                                        .frame(width:80, height: 36)
                                        .background(Color.green)
                                        .cornerRadius(5)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.9))
                        .padding(.bottom, bottomTextFieldPadding)
                        .zIndex(10)
                    }
                }
                
                
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all).opacity(showPinView ? 0.6 : 0)
                        .onTapGesture {
                            showPinView.toggle()
                        }
                    VStack {
                        Text("Enter Your PIN")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        GeometryReader { proxy in
                            PassCodeCodeView(viewWidth: proxy.size.width/5) { passCode in
                                
                                print(passCode)
                                mainVM.selectedCode = mainVM.selectedDialer.value + passCode + "#"
                                mainVM.dial()
                                showPinView = false
                            }
                        }
                        .frame(height: 85)
                    }
                    .frame(height: 150)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 3)
                    .padding()
                    .offset(y: -100)
                    .offset(y: showPinView ? 0 : 1200)
                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                    .zIndex(30)
                }
                
            }
            .background(
                Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("") //"Dialers📞📱☎️
            .navigationBarHidden(true)
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(MainViewModel())
    }
}


