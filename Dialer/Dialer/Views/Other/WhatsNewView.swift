//
//  WhatsNewView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/02/2022.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var isPresented: Bool
    
    private let changeLogs: [ChangeLog] = ChangeLog.latestLogs
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Image("dialit.applogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .cornerRadius(20)
                        
                        VStack {
                            Text("Dialer")
                                .font(.system(.title, design: .rounded).weight(.heavy))
                            
                            Text("Your USSD companion app.")
                                .font(.headline)
                                .opacity(0.95)
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 18) {
                        
                        Text("What's in for you?")
                            .font(.system(.title2, design: .rounded).weight(.heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        
                        VStack(spacing: 20) {
                            ForEach(changeLogs, content: ChangeLogView.init)
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .padding(.horizontal)
            }
            
            
            Button {
                isPresented = false
            } label: {
                Text("Continue")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .shadow(color: .lightShadow, radius: 3, x: -3, y: -3)
                    .shadow(color: .darkShadow, radius: 3, x: 3, y: 3)
                    .foregroundStyle(.white)
            }
            .padding([.horizontal,.bottom])
        }
        .background(Color.primaryBackground)
    }

    private struct ChangeLogView: View {
        let log: ChangeLog
        
        var body: some View {
            
            HStack(spacing: 10) {
                
                Image(systemName: log.icon)
                    .resizable()
                    .foregroundColor(.mainRed)
                    .brightness(0.1)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading) {
                    Text(log.title)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .contrast(0.85)
                    
                    Text(log.subtitle)
                        .opacity(0.8)
                        .font(.system(.callout, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isPresented: .constant(true))
    }
}
#endif


private struct ChangeLog: Identifiable {
    var id: UUID { UUID() }
    let icon: String
    let title: String
    let subtitle: String
    init(_ icon: String, _ title: String, _ subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}
    
private extension ChangeLog {
    static let version500 = [
        ChangeLog("phone.circle", "Airtime", "Ability to quickly generate USSD for buying airtime."),
        ChangeLog("clock.arrow.circlepath", "History", "Get direct access to your frequently used USSD codes."),
        ChangeLog("francsign.circle", "Transfer/Pay", "Get the right USSD code for transferring to your friend or paying to the store."),
        ChangeLog("wrench.and.screwdriver", "My Space", "A unified space for buying electricity, Voice packs, Internet and more.")
    ]
    
    static var latestLogs: [ChangeLog] {
        version500
    }
}
