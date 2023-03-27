//
//  WhatsNewView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/02/2022.
//

import SwiftUI

struct WhatsNewView: View {
    @Binding var isPresented: Bool
    
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
                    
                    VStack(spacing: 18) {
                        
                        Text("What's in for you?")
                            .font(.system(.title, design: .rounded).weight(.heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        
                        VStack(spacing: 20) {
                            
                            featureView(icon: "phone.circle",
                                        title: "Airtime",
                                        subtitle: "Ability to quickly generate USSD for buying airtime.")
                            
                            featureView(icon: "clock.arrow.circlepath",
                                        title: "History",
                                        subtitle: "Get direct access to your frequently used USSD codes.")
                            
                            featureView(icon: "francsign.circle",
                                        title: "Transfer/Pay",
                                        subtitle: "Get the right USSD code for transfering to your friend or paying to the store.")
                            
                            featureView(icon: "wrench.and.screwdriver",
                                        title: "My Space",
                                        subtitle: "A unified space for buying electricity, Voice packs, Internet and more.")
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
                    .background(Color.primaryBackground)
                    .cornerRadius(15)
                    .shadow(color: .lightShadow, radius: 3, x: -3, y: -3)
                    .shadow(color: .darkShadow, radius: 3, x: 3, y: 3)
                    .foregroundColor(.mainRed)
            }
            .padding([.horizontal,.bottom])
        }
        .background(Color.primaryBackground)
    }

    private func featureView(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {

        HStack(spacing: 10) {

            Image(systemName: icon)
                .resizable()
                .foregroundColor(.mainRed)
                .brightness(0.1)
                .scaledToFit()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .contrast(0.85)

                Text(subtitle)
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

#if DEBUG
struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isPresented: .constant(true))
//            .previewIn(.fr)
//            .preferredColorScheme(.dark)
    }
}
#endif
