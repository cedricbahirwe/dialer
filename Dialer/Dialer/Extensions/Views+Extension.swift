//
//  Views+Extension.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 06/06/2021.
//

import SwiftUI

struct MTNDisabling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .disabled(CTCarrierDetector.shared.cellularProvider().status == false)
    }
}

extension Color {
    static let main = Color("main")
}

extension View {
    
    /// Disable access if `Mtn` sim card is not detected
    /// - Returns: a disabled view if mtn card is not detected (no interaction).
    func momoDisability() -> some View {
        ModifiedContent(content: self, modifier: MTNDisabling())
    }
    
    
    /// Dismiss keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func drawImage(_ name: String, size: CGSize = CGSize(width: 60, height: 40)) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        // Draw image in circle
        let image = UIImage(named: name)!
        let size = CGSize(width: 55, height: 35)
        let rect = CGRect(x: 0, y: 5, width: size.width, height: size.height)
        image.draw(in: rect)
    }
}
