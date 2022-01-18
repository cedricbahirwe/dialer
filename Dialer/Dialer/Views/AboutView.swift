//
//  AboutView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 22/09/2021.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject
    private var dataStore: MainViewModel
    
    private let appVersion = UIApplication.appVersion ?? "1.0"
    private let buildVersion = UIApplication.buildVersion ?? "1"
    
    var body: some View {
        VStack {
            Image("dialit.applogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .cornerRadius(12)
                .padding(30)

            VStack(spacing: 20) {
                Text("Dial It Version \(appVersion)")
                    .fontWeight(.bold)
                
                Text("Build \(buildVersion)")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text("Designed and developed by\nCédric Bahirwe from ABC Incs.")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .navigationBarTitle("About")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dataStore.dismissSettingsView()
                }.font(.body.bold())
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
