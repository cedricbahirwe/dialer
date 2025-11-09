//
//  DialerSplitInfoView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct DialerSplitInfoView: View {
    @Binding var isPresented: Bool
    var onTurnOn: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: AppConstants.dialerSplitsIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red, .purple, .accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 10)

            Text("Dialer Splits")
                .font(.system(.title, design: .rounded, weight: .bold))
                .bold()

            Text(Bool.random()
                 ? "Save on transaction fees with smart split suggestions when sending money."
                 : "Get smart suggestions to reduce transaction fees when sending money.")
            .font(.headline)
            .fontWeight(.regular)
            .multilineTextAlignment(.center)

            Label("You can change this in the app settings.", systemImage: "info.circle")
                .font(.callout)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                Button {
                    isPresented.toggle()
                    onTurnOn()
                } label: {
                    Text("Turn on Split Suggestions")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red, .purple, .accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: .rect(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)

                Button {
                    isPresented = false
                } label: {
                    Text("Remind Me Later")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                }
            }
            .padding(.top, 12)
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    DialerSplitInfoView(isPresented: .constant(true), onTurnOn: {})
}
