//
//  WhatsNewView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/02/2022.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image("dialit.applogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75)
                            .cornerRadius(20)

                        VStack {
                            Text("Dialer")
                                .font(.system(.title, design: .rounded).weight(.heavy))

                            Text("Your USSD companion app.")
                                .font(.headline)
                                .opacity(0.9)
                        }
                    }
                    .padding(.top, 16)

                    Section {
                        VStack(spacing: 15) {
                            ForEach(whatsNewLogs, content: ChangeLogView.init)
                        }
                        .padding(.horizontal, 2)

                        Capsule()
                            .fill(smartGradient)
                            .frame(height: 1.5)
                            .padding(.leading, 40)
                            .padding(.trailing)

                        VStack(spacing: 15) {
                            ForEach(latestLogs, content: ChangeLogView.init)
                        }
                        .padding(.horizontal, 2)
                    } header: {
                        Text("What's New")
                            .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    }
                }
                .padding(.horizontal)
            }

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        Color.accentColor
                            .shadow(.drop(color: .lightShadow, radius: 3, x: -3, y: -3))
                            .shadow(.drop(color: .darkShadow, radius: 13, x: 3, y: 3))
                        ,
                        in: .rect(
                            cornerRadius: 15
                        )
                    )
            }
            .padding()
            .tint(.white)
        }
        .background(Color.primaryBackground)
    }
}

private extension WhatsNewView {
    struct ChangeLogView: View {
        let log: ChangeLog
        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: log.icon)
                    .resizable()
                    .foregroundStyle(.mainRed)
                    .brightness(0.1)
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading) {
                    Text(log.title)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .opacity(0.9)

                    Text(log.subtitle)
                        .foregroundStyle(.secondary)
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

#Preview {
    WhatsNewView()
//        .preferredColorScheme(.dark)
}

private extension WhatsNewView {
    var whatsNewLogs: [ChangeLog] {
        [
            ChangeLog(AppConstants.dialerSplitsIconName, "Dialer Splits", "Save on transaction fees with smart split suggestions when sending money."),
            ChangeLog("lightbulb.max.fill", "Insights", "Gain valuable insights into your transactions history and USSD usage.")
        ]
    }
    

    var latestLogs: [ChangeLog] {
        [
            ChangeLog("paperplane.circle", "Transfer & Pay", "Easily find the USSD code for sending money or making store payments."),
            ChangeLog("phone.circle", "Buy Airtime", "Quickly generate the right USSD code to top up airtime in seconds."),
            ChangeLog("folder", "My Space", "Personalize and manage your own USSD codes for quick access whenever needed.")
        ]
    }
}

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
