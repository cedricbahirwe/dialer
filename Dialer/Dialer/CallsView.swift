//
//  CallsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI

struct CallsView: View {
    @State private var goToIrekure = false
    @EnvironmentObject var mainVM: MainViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HeaderView(title: "Calls Menu")
            NavigationLink(destination: CallsSecondView(), isActive: $goToIrekure) { }
            ScrollView {
                DialerRow(title: "MTN Irekure! (24hrs)") {
                    goToIrekure.toggle()
                }
                DialerRow(title: "Supapack All Networks (24hrs)")
                DialerRow(title: "Supapack Weekly All Networks")
                DialerRow(title: "International")
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct CallsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            //            CallsView()
            CallsThirdView()
        }
    }
}

struct CallsSecondView: View {
    @EnvironmentObject var mainVM: MainViewModel
    
    @State private var goToOtherPacks = false
    var body: some View {
        VStack(spacing: 10) {
            HeaderView(title: "Pick one option")
            NavigationLink(destination: CallsThirdView(), isActive: $goToOtherPacks) { }
            ScrollView {
                DialerRow(title: "MTN All Networks")
                DialerRow(title: "Other Packs") {
                    goToOtherPacks.toggle()
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        
    }
}
struct CallsThirdView: View {
    @EnvironmentObject var mainVM: MainViewModel
    
    @State var options = [
        "100 RWF = 1200S (20M) + 20 SMS",
        "150 RWF = 2100S (35M) + 20 SMS + 5 MBs",
        "200 RWF = 3600S (60M) + 20 SMS + 5MBs"
    ]
    var body: some View {
        VStack (spacing: 10) {
            HeaderView(title: "Pick one option")
            ScrollView {
                ForEach(0..<options.count, id:\.self) { index  in
                    DialerRow(title: options[index]) {
//                        mainVM.selectedCode = "*140*1*2*\(index+1)#"
//                        mainVM.dial()
                    }
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

