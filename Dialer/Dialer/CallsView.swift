//
//  CallsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI

struct CallsView: View {
    @State private var options:[String] = [
        "MTN Irekure! (24hrs)",
        "Supapack All Networks (24hrs)",
        "Supapack Weekly All Networks",
        "International",
        "Balance",
    ]
    var body: some View {
        VStack {
            List(options, id:\.self) { option in
                Text(option)
            }
            .listStyle(PlainListStyle())
            
            
        }
        .navigationBarHidden(false)
        .navigationBarTitle("Calls", displayMode: .inline)
    }
}

struct CallsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CallsView()
        }
    }
}

struct CallsSecondView: View {
    @State private var options:[String] = [
        "MTN All Networks",
        "Other Packs",
    ]
    var body: some View {
        List(options, id:\.self) { option in
            Text(option)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Call options")
        
    }
}
struct CallsThirdView: View {
    @State private var options:[String] = [
        "100 RWF = 1200S (20M) + 20 SMS",
        "150 RWF = 2100S (35M) + 20 SMS + 5 MBs",
        "200 RWF = 3600S (60M) + 20 SMS + 5MBs"
    ]
    var body: some View {
        List(options, id:\.self) { option in
            Text(option)
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Select one option options")
        
    }
}
