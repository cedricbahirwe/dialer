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
                Text("Dialer")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                
            }
            .padding(.top, 30)
            
            Text("Version \(appVersion) (\(buildVersion))")
                .fontWeight(.bold)
            
            VStack(spacing: 2) {
                Text("Designed and developed by")
                    .foregroundStyle(.secondary)
                Link("Cédric Bahirwe.", destination: DialerlLinks.authorLinkedIn)
            }
            .font(.body.weight(.semibold))
            
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
        .trackAppearance(.about)
    }
}

#Preview {
    NavigationStack {
        AboutView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
