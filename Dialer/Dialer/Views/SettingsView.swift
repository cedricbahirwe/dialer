//
//  SettingsView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 02/09/2021.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var data: MainViewModel
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
                VStack(alignment: .leading, spacing: 0) {
                    
                    Section(header:
                                sectionHeader("General settings")
                                .font(.headline.weight(.semibold))
                    ) {
                        VStack {
                            if data.hasStoredPinCode {
                                ForEach(generalItems, id:\.self) { item in
                                    SettingsRow(item, action: data.removePin)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    
                    
                    Section(header:
                                sectionHeader("Tips and Guides")
                                .font(.headline.weight(.semibold))
                    ) {
                        VStack {
                            ForEach(tipsAndGuidesItems, id:\.self) { item in
                                SettingsRow(item, action: {})
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    
                    Section(header:
                                sectionHeader("Reach Out")
                                .font(.headline.weight(.semibold))
                    ) {
                        VStack {
                            ForEach(reachoutItems, id:\.self) { item in
                                SettingsRow(item, action: {})
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    Section(header: sectionHeader("Colophon")) {
                        VStack {
                            ForEach(colophonItems, id:\.self) { item in
                                SettingsRow(item, action: {})
                            }
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
//            .font(.system(.largeTitle, design: .monospaced))
            .navigationTitle("Help & More")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                Text("Done")
//                    .bold()
//                    .foregroundColor(.blue)
//                    .onTapGesture {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    
    private func sectionHeader(_ title: String) -> Text {
        Text(title)
            .font(.system(.headline, design: .rounded))
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
        
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
        let isSystemImage: Bool
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MainViewModel())
//            .preferredColorScheme(.dark)
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
            Button(action: {}, label: {
                contenView
            })
        }
        
        var contenView: some View {
            HStack {
                icon
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
