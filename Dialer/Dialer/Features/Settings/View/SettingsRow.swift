//
//  SettingsRow.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 07/11/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct SettingsRow: View {
    init(item: SettingsItem, action: @escaping () -> Void) {
        self.item = item
        self.action = action
    }

    init(_ option: SettingsOption, action: @escaping () -> Void) {
        self.init(item: option.getSettingsItem(), action: action)
    }

    init(_ option: SettingsOption) {
        self.item = option.getSettingsItem()
        self.action = nil
    }

    private let item: SettingsItem
    private let action: (() -> Void)?

    var body: some View {
        if let action = action {
            Button(action: action) { contentView }
        } else {
            contentView
        }
    }

    @State private var animateSymbol = false

    private var iconImageView: some View {
        item.icon
            .resizable()
            .scaledToFit()
            .padding(6)
            .frame(width: 28, height: 28)
            .background(item.color)
            .cornerRadius(6)
            .foregroundStyle(.white)
    }

    var contentView: some View {
        HStack(spacing: 0) {
            if #available(iOS 17.0, *) {
                iconImageView
                    .symbolEffect(.bounce.down, value: animateSymbol)
            } else {
                iconImageView
            }

            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.system(.callout, design: .rounded))
                Text(item.subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)

            }
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.8)
            .padding(.leading, 15)

            Spacer(minLength: 1)
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                animateSymbol = true
            }
        }
    }
}
