//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject
    private var dataStore: MainViewModel
    
    private let appearanceItems: [SettingsItem] = [
        .init(sysIcon: "trash", color: .red, title: "Change Icon",
              subtitle: "Choose the right fit for you.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Section(header:
                                sectionHeader("General settings")
                                .font(.headline.weight(.semibold))
                    ) {
                        VStack {
                            if dataStore.hasStoredPinCode {
                                SettingsRow(.deletePin, action: dataStore.removePin)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    
                    
                    Section(header:
                                sectionHeader("Tips and Guides")
                                .font(.headline.weight(.semibold))
                    ) {
                        VStack {
                            SettingsRow(.getStarted, action: {})
                        }
                        .padding(.bottom, 20)
                    }
                    
                    Section(header:
                                sectionHeader("Reach Out")
                    ) {
                        VStack {
                            SettingsRow(.contactUs, action: {})
                            Link(destination: URL(string: "https://twitter.com/TheDialerApp")!) {
                                SettingsRow(.tweetUs)
                            }
                            
                            SettingsRow(.translationSuggestion, action: {})
                        }
                        .padding(.bottom, 20)
                    }
                    Section(header: sectionHeader("Colophon")) {
                        
                        VStack {
                            NavigationLink(destination: AboutView()) {
                                SettingsRow(.about)
                            }
                            SettingsRow(.review, action: {})
                        }
                        .padding(.bottom, 20)
                    }
                }
                .padding(10)
                .foregroundColor(.primary.opacity(0.8))
                
                
                Group {
                    Text("By using Dialer, you accept our")
                    
                    HStack(spacing: 0) {
                        Link("Terms & Conditions", destination: URL(string: "www.google.com")!)
                        Text(" and ")
                        Link("Privacy Policy", destination: URL(string: "www.google.com")!)
                    }
                    .padding(.bottom, 20)
                }
                .font(.subheadline)
            }
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dataStore.dismissSettingsView()
                    }.font(.body.bold())
                }
            }
        }
    }
    
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .padding(.vertical)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MainViewModel())
    }
}
extension SettingsView {
    
    struct SettingsRow: View {
        
        init(_ option: SettingsOption,
             action: @escaping () -> Void) {
            self.item = option.getItem()
            self.action = action
        }
        init(_ option: SettingsOption) {
            self.item = option.getItem()
            self.action = nil
        }
        
        let item: SettingsItem
        let action: (() -> Void)?
        
        var body: some View {
            if let action = action {
                Button(action: action, label: {
                    contenView
                })
            } else {
                contenView
            }
        }
        
        var contenView: some View {
            HStack(spacing: 15) {
                item.icon
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .frame(width: 30, height:30)
                    .background(item.color)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.system(.callout, design: .rounded))
                    Text(item.subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 5)
        }
    }
}
