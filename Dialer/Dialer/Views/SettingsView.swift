//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode)
    private var presentationMode
    private let colophonItems: [SettingsItem] = [
        .init(sysIcon: "info", color: .orange, title: "About", subtitle: "Version information."),
        .init(sysIcon: "heart.fill", color: .red, title: "Review Dialer", subtitle: "Let us know how we are doing."),
        
    ]
    
    private let reachoutItems: [SettingsItem] = [
        .init(sysIcon: "bubble.left.and.bubble.right.fill", color: .pink, title: "Contact Us", subtitle: "Get help or ask a question."),
        .init(icon: "twitter", color: Color("twitter"), title: "Tweet Us", subtitle: "Stay up to date."),
        
            .init(icon: "translation", color: .blue, title: "Translation Suggestion", subtitle: "Improve our localization.")
    ]
    
    private let tipsAndGuidesItems: [SettingsItem] = [
        .init(sysIcon: "lightbulb.fill", color: .blue, title: "Just getting started?", subtitle: "Read our quick start blog post."),
    ]
    
    private let generalItems: [SettingsItem] = [
        .init(sysIcon: "trash", color: .red, title: "Remove Momo Pin",
              subtitle: "You'll need to re-enter it later.")
    ]
    
    private let appearanceItems: [SettingsItem] = [
        .init(sysIcon: "trash", color: .red, title: "Change Icon",
              subtitle: "Choose the right fit for you.")
    ]
    
    
    
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    Section(header:
                                sectionHeader("General settings")
                                .font(.headline.weight(.semibold))
                    ) {
                        
                        ForEach(generalItems, id:\.self) { item in
                            SettingsRow(item, action: {})
                        }
                        
                    }
                    
                    
                    Section(header:
                                sectionHeader("Tips and Guides")
                                .font(.headline.weight(.semibold))
                    ) {
                        
                        ForEach(tipsAndGuidesItems, id:\.self) { item in
                            SettingsRow(item, action: {})
                        }
                        
                    }
                    
                    Section(header:
                                sectionHeader("Reach Out")
                                .font(.headline.weight(.semibold))
                    ) {
                        
                        ForEach(reachoutItems, id:\.self) { item in
                            SettingsRow(item, action: {})
                        }
                        
                    }
                    Section(header: sectionHeader("Colophon")) {
                        
                        ForEach(colophonItems, id:\.self) { item in
                            SettingsRow(item, action: {})
                        }
                        
                    }
                }
                .padding(10)
                .foregroundColor(.primary.opacity(0.8))

                
                Text("By using Dialer, you accept our")
                
                HStack(spacing: 0) {
                    Link("Terms & Conditions", destination: URL(string: "www.google.com")!)
                    Text(" and ")
                    Link("Privacy Policy", destination: URL(string: "www.google.com")!)
                }
                
                
            }
            .toolbar {
                Text("Done")
                    .bold()
                    .foregroundColor(.blue)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    private func sectionHeader(_ title: String) -> Text {
        Text(title)
            .font(.headline.weight(.semibold))
    }
    
    struct SettingsItem: Hashable {
        init(icon: String, color: Color, title: String, subtitle: String) {
            self.icon = icon
            self.color = color
            self.title = title
            self.subtitle = subtitle
            isSystemImage = false
        }
        
        init(sysIcon: String, color: Color, title: String, subtitle: String) {
            self.icon = sysIcon
            self.color = color
            self.title = title
            self.subtitle = subtitle
            isSystemImage = true
        }
        
        var icon: String
        var color: Color
        var title: String
        var subtitle: String
        
        let isSystemImage: Bool
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
extension SettingsView {
    struct SettingsRow: View {
        init(_ item: SettingsItem,
             action: @escaping () -> Void) {
            self.item = item
            self.action = action
        }
        let item: SettingsItem
        let action: () -> Void
        
        
        private var icon: Image {
            item.isSystemImage ? Image(systemName: item.icon) :Image(item.icon)
        }
        var body: some View {
            HStack {
                icon
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .frame(width: 30, height: 30)
                    .background(item.color)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.callout)
                    Text(item.subtitle)
                        .font(.caption)
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
