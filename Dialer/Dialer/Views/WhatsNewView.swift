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
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Image("dialit.applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .cornerRadius(20)

                VStack {
                    Text("Dial It")
                        .font(.system(.title, design: .rounded).weight(.heavy))

                    Text("Your USSD companion app.")
                        .font(.headline)
                        .opacity(0.95)
                }

            }

            VStack(spacing: 18) {

                Text("What's in for you?")
                    .font(.system(.title, design: .rounded).weight(.heavy))

                ScrollView(.vertical, showsIndicators: true) {
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
                                    title: "Utilities",
                                    subtitle: "Get USSD codes for buying electricity, Voice packs, Internet bundles and more.")


                        HStack {
                            Image(systemName: "info.circle")
                            Text("This version includes support for **iOS 15.5** ")
                                .lineLimit(1)

                        }
                        .padding(8)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(Color.cyan.opacity(0.15))
                        .cornerRadius(15)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(.teal)

                    }
                    .padding(.horizontal, 2)
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
                .padding(.vertical)
            }
        }
        .padding()
        .background(Color.primaryBackground)
    }

    private func featureView(icon: String, title: String, subtitle: String) -> some View {

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
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
//                    .scaleEffect(0.95, anchor: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}
