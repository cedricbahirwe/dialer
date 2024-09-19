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

                    VStack(spacing: 16) {
                        Text("Cool Stuff You Can Do!")
                            .font(.system(.title2, design: .rounded).weight(.heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)

                        VStack(spacing: 15) {
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
            }
            .background(
                Color.accentColor
                    .shadow(.drop(color: .lightShadow, radius: 3, x: -3, y: -3))
                    .shadow(.drop(color: .darkShadow, radius: 13, x: 3, y: 3))
                ,
                in: .rect(
                    cornerRadius: 15
                )
            )
            .padding([.horizontal,.bottom])
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

#Preview {
    WhatsNewView(isPresented: .constant(true))
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

private extension ChangeLog {
    static var latestLogs: [ChangeLog] {
        [
            ChangeLog("paperplane.circle", "Transfer & Pay", "Easily find the USSD code for sending money or making store payments."),
            ChangeLog("phone.circle", "Buy Airtime", "Quickly generate the right USSD code to top up airtime in seconds."),
            ChangeLog("bubbles.and.sparkles.fill", "Insights", "Gain valuable insights into your transaction history and USSD code usage."),
            ChangeLog("folder", "My Space", "Personalize and manage your own USSD codes for quick access whenever needed."),
        ]
    }
}
