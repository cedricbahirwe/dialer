//
//  WrappedPreview.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 26/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct WrappedPreview: View {
    var onStart: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Your 2024 Wrapped")
                .font(.largeTitle)
                .fontWeight(.heavy)

            Text("Discover your 2024 highlights")
                .font(.title3)

            Button(action: {
                onStart()
            }, label: {
                Text("Let's go")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(width: 90, height: 38)
                    .background(.mainRed, in: .capsule)
                    .foregroundStyle(.background)
                    .foregroundStyle(.regularMaterial)
            })
            .padding()
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(WrappedPreviewBackground())
        .background(Color.primaryBackground)
        .cornerRadius(25)
        .shadow(color: .lightShadow, radius: 4, x: -3, y: -3)
        .shadow(color: .darkShadow, radius: 4, x: 3, y: 3)
        .background(.regularMaterial, in: .rect(cornerRadius: 25))
        .contentShape(.rect)
        .onTapGesture {
            onStart()
        }
//        .foregroundStyle(.white)
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    WrappedPreview(onStart: {})
}
