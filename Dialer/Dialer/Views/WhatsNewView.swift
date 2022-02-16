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
            VStack(spacing: 6) {
                Image("dialit.applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .cornerRadius(20)

                Text("Dial It")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))

                Text("Your Rwanda reference for USSD codes.")
                    .font(.headline)
                Text("No need to memorize all USSD codes!\n**Dial It** is there for you!📞")
                    .font(.system(.callout, design: .serif))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {

                Text("What's In for You👀?")
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
                        .background(Color.mainRed)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }

    private func featureView(icon: String, title: String, subtitle: String) -> some View {

        HStack(spacing: 10) {

            Image(systemName: icon)
//                            .symbolRenderingMode(.monochrome)
                .resizable()
                .foregroundColor(.mainRed)
                .brightness(0.1)
                .scaledToFit()
                .frame(width: 42, height: 42)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .contrast(0.85)

                Text(subtitle)
                    .opacity(0.8)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isPresented: .constant(true))
//            .preferredColorScheme(.dark)
    }
}
