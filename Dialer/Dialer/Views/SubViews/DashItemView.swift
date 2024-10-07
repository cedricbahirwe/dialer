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
        VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
                    )

            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .background(Color.primaryBackground)
        .cornerRadius(15)
        .contentShape(Rectangle())
        .shadow(color: .lightShadow, radius: 4, x: -4, y: -4)
        .shadow(color: .darkShadow, radius: 4, x: 4, y: 4)

    }
}

@available(iOS 17.0, *)
#Preview("DashItem View", traits: .fixedLayout(width: 200, height: 130)) {
    DashItemView(title: "Title", icon: "house.fill")
        .padding(.horizontal)
}
