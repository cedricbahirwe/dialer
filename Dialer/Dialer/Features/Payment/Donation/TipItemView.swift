//
//  TipItemView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI
import StoreKit

struct TipItemView: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(product.displayName)
                    .font(.headline)

                Text(product.displayPrice)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text(product.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isSelected ? 2 : 0.03)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//#Preview {
//    TipItemView()
//}
