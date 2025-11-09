//
//  DashItemView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/09/2022.
//

import SwiftUI

struct DashItemView: View {
    let title: LocalizedStringKey
    let icon: String

    var body: some View {
        if #available(iOS 26.0, *) { 
            contentView
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
        } else {
            contentView
            .background(.background, in: .rect(cornerRadius: 15))
            .shadow(color: .lightShadow, radius: 4, x: -4, y: -4)
            .shadow(color: .darkShadow, radius: 4, x: 4, y: 4)
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [Color.red, Color.accent]), startPoint: .topLeading, endPoint: .trailing)
                    )
                    .accessibilityHidden(true)

            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 85)
        .contentShape(.rect(cornerRadius: 15))
    }
}

@available(iOS 17.0, *)
#Preview("DashItem View", traits: .fixedLayout(width: 200, height: 130)) {
    DashItemView(title: "Title", icon: "house.fill")
        .padding(.horizontal)
}
