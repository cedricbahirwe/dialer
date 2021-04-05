//
//  Helpers.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 08/02/2021.
//

import Foundation
import SwiftUI
import Combine

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
extension UIApplication {
    func endEditing(_ force: Bool) {
        windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
    
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

