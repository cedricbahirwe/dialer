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
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
                .frame(width: 25, height: 25)
                .mask(
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )

            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
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

struct DashItemView_Previews: PreviewProvider {
    static var previews: some View {
        DashItemView(title: "Title", icon: "house.fill")
            .padding()
            .previewLayout(.fixed(width: 200, height: 150))
            .previewDisplayName("DashItem View")
    }
}
