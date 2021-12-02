//
//  UtilitiesView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/11/2021.
//

import SwiftUI

struct UtilitiesView: View {
    var body: some View {
        VStack {
            List {
                
                Section("Primary") {
                    NavigationLink {
                        Text("Electricity")
                    } label: {
                        Text("Buy Electricity")
                    }

                    Text("Check Momo Balance")
                }
                
                Section("Secondary") {
                    Text("Check Airtime Balance")
                    
                    Text("Check Internet Bundles")
                    
                    NavigationLink {
                        Text("Voice")
                    } label: {
                        Text("Buy Voice Packs")
                    }
                    
                    Text("Check Voice Packs Balance")
                    
                    Text("Check my number")
                }
            }
        }
        .navigationTitle("Utilities")
    }
}

struct UtilitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UtilitiesView()
        }
    }
}
