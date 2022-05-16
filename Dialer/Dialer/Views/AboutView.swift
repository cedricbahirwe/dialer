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
        VStack(spacing: 30) {

            VStack {
                Image("dialit.applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .cornerRadius(15)
                Text("Dial It")
                    .font(.system(.title3, design: .rounded).weight(.bold))

            }
            .padding(.top, 30)

            VStack(spacing: 10) {
                Text("Version \(appVersion)")
                    .fontWeight(.bold)

                Text("Build \(buildVersion)")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            Text("Designed and developed by\n[Cédric Bahirwe](https://twitter.com/cedricbahirwe)")
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.primaryBackground)
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
                .preferredColorScheme(.dark)
        }
    }
}
