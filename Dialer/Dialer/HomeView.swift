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
    
    @State private var borderCodeColor = Color(.label)
    @State private var securePassCode = true
    
    @State private var goToCallsView = false
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
                    
                    NavigationLink(destination: CallsView(), isActive: $goToCallsView) { Text("") }
                    ScrollView {
                        VStack(alignment: .leading) {
                            DialerRow(title: "Buy Internet Bundle ⏰")
                            DialerRow(title: "Buy Call Packs 📞") {
                                goToCallsView.toggle()
                            }
                            DialerRow(title: "Buy with Mobile Money 💰")
                            DialerRow(title: "Check Airtime Balance ⚖️", perfom: mainVM.dial)
                            DialerRow(title: "Check Mobile Money Balance ⚖️💲") {
                                showPinView.toggle()
                                mainVM.selectedDialer = .momo(option: .balance)
                            }
                            DialerRow(title: "Settings ⚙️")

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
                            UIApplication.shared.endEditing(true)
                            showPinView.toggle()
                        }
                    VStack {
                        HStack {
                            Text("Enter Your PIN")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                            
                            Image(systemName: securePassCode ? "eye.fill" : "eye.slash.fill")
                                .imageScale(.large)
                                .onTapGesture {
                                    withAnimation {
                                        securePassCode.toggle()
                                    }
                                }
                        }
                        
                            
                        GeometryReader { proxy in
                            PassCodeCodeView(secureFields: $securePassCode, viewWidth: proxy.size.width/5) { passCode in
                                mainVM.selectedCode = mainVM.selectedDialer!.value + passCode + "#"
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
                    .shadow(color: Color(.label), radius: 3)
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
            .navigationBarTitle("", displayMode: .inline) //"Dialers📞📱☎️
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


