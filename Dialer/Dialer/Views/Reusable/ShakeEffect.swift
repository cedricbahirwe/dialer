//
//  ShakeEffect.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/03/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//
import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
