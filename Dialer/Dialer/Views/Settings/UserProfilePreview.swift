//
//  UserProfilePreview.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/11/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct UserProfilePreview: View {
    let info: AppleInfo
    var onSignOut: () -> Void
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 55)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .trailing
                    )
                )

            VStack(alignment: .leading) {
                Text(info.fullname?.formatted() ?? "Unknown")
                Text(info.email ?? "-")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Sign Out", action: onSignOut)
                .font(.callout)
                .foregroundStyle(.red)
        }
    }
}
